import logging
import os
import time
import usb.core
import usb.util
import serial
import subprocess
import signal
from multiprocessing import Process, Manager, Queue
from rich.console import Console
from rich.table import Table

shutdown_flag = False

def signal_handler(sig, frame):
    global shutdown_flag
    shutdown_flag = True

def log_manager(queue):
    documents_dir = os.path.join(os.path.expanduser("~"), "Documents")
    log_dir = os.path.join(documents_dir, 'peripheral_logs')

    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logger = logging.getLogger("CentralLogger")
    logger.setLevel(logging.DEBUG)

    handler = logging.FileHandler(os.path.join(log_dir, 'logs_debug.log'))
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    logger.debug("Logger initialized successfully.")

    device_loggers = {}

    while True:
        message = queue.get()
        if message is None:  
            break
        
        device_name, level, msg = message

        if device_name not in device_loggers:
            device_loggers[device_name] = logging.getLogger(device_name)
            device_loggers[device_name].setLevel(logging.DEBUG)
            device_handler = logging.FileHandler(os.path.join(log_dir, f'{device_name}_log.log'))
            device_handler.setFormatter(formatter)
            device_loggers[device_name].addHandler(device_handler)

        if level == 'info':
            device_loggers[device_name].info(msg)
        elif level == 'error':
            device_loggers[device_name].error(msg)
        elif level == 'warning':
            device_loggers[device_name].warning(msg)
        elif level == 'debug':
            device_loggers[device_name].debug(msg)

class PeripheralMonitor:
    def __init__(self, queue, device_name):
        self.queue = queue
        self.device_name = device_name
        self.status = "Idle"
        self.running = True
        self.last_status = None
        self.last_log_time = time.time()  
        self.logs = []  

    def log_status_if_changed(self, status_updates, status, last_data, last_send):
        log_message = f"Device: {self.device_name} | Status: {status} | Last Data: {last_data or 'None'} | Last Send: {last_send}"

        current_time = time.time()
        save_logs = False  

        if log_message != self.last_status:
            if len(self.logs) > 1 and log_message == self.logs[-1]:
                return  

            self.logs.append(log_message)
            if len(self.logs) > 10:  
                self.logs.pop(0)

            status_updates[self.device_name] = {
                'status': status,
                'last_data': last_data,
                'last_sent': last_send
            }

            save_logs = True  
            self.last_status = log_message 
            self.last_log_time = current_time 

        if current_time - self.last_log_time >= 300: 
            save_logs = True

        if save_logs:
            if len(self.logs) >= 4:
                self.save_last_logs(self.logs[-4:]) 

            self.last_log_time = current_time

    def save_last_logs(self, last_logs):
        log_file_path = os.path.join(os.path.expanduser("~"), "Documents", "peripheral_logs", f'{self.device_name}_last_logs.log')
        with open(log_file_path, 'a') as log_file:
            for log in last_logs:
                log_file.write(log + '\n')

class SerialPeripheral(PeripheralMonitor):
    def __init__(self, queue, device_name, port):
        super().__init__(queue, device_name)
        self.port = port
        self.baud_rate = 115200
        self.timeout = 5
        self.cmd_pd = b'\x02V\x03W'
        self.ser = None

    def connect(self):
        self.log_status_if_changed({}, "Connecting", None, None)
        try:
            self.ser = serial.Serial(self.port, baudrate=self.baud_rate, timeout=self.timeout)
            self.log_status_if_changed({}, "Connected", None, None)
        except serial.SerialException as e:
            self.log_status_if_changed({}, "Inactive - Connection Failed", None, None)
            self.queue.put((self.device_name, 'error', f"Failed to connect to {self.port}: {e}"))
            self.ser = None

    def monitor(self, status_updates):
        self.connect()
        while self.running and not shutdown_flag:
            if not self.ser:
                self.log_status_if_changed(status_updates, "Inactive - Connection Failed", None, None)
                time.sleep(5)
                self.connect()
                continue

            try:
                self.ser.write(self.cmd_pd)
                self.log_status_if_changed(status_updates, "Active", None, None)

                response = self.ser.readline()
                if response:
                    resp_data = response[2:-1].decode('utf-8', errors='ignore')
                    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    self.log_status_if_changed(status_updates, "Active", resp_data, current_time)
                else:
                    self.log_status_if_changed(status_updates, "Inactive - No Data", None, None)

            except Exception as e:
                self.queue.put((self.device_name, 'error', f"Error during communication: {e}"))
                self.log_status_if_changed(status_updates, "Inactive - Error", None, None)
                self.reconnect()

            time.sleep(5)

    def reconnect(self):
        self.log_status_if_changed({}, "Reconnecting...", None, None)
        self.connect()

    def stop(self):
        self.running = False
        if self.ser:
            self.ser.close()

class USBPeripheral(PeripheralMonitor):
    vid = 0x1abd
    pid = 0x0001 

    def connect_device(self):
        self.log_status_if_changed({}, "Connecting to USB device...", None, None)
        self.dev = usb.core.find(idVendor=self.vid, idProduct=self.pid)
        if self.dev is None:
            self.log_status_if_changed({}, "Inactive - Device Not Found", None, None)
            raise ValueError("Device not found")

        self.dev.set_configuration()
        cfg = self.dev.get_active_configuration()
        self.intf = cfg[(0, 0)]

        self.ep_out = usb.util.find_descriptor(
            self.intf,
            custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_OUT
        )

        assert self.ep_out is not None, "Output endpoint not found"

        self.ep_in = usb.util.find_descriptor(
            self.intf,
            custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_IN
        )

        assert self.ep_in is not None, "Input endpoint not found"

        self.log_status_if_changed({}, "Device connected successfully.", None, None)

    def monitor(self, status_updates):
        while self.running:
            try:
                self.connect_device()
            except ValueError as e:
                self.log_status_if_changed(status_updates, "Inactive - Device Not Found", None, None)
                time.sleep(10)
                continue

            version_command = bytes([0x1b, 0x1a, 0x08, 0x43])  

            while self.running:
                try:
                    self.ep_out.write(version_command)
                    response = self.ep_in.read(8)

                    if len(response) == 0:
                        self.log_status_if_changed(status_updates, "Inactive - No Data", None, None)
                        break  

                    version = ''.join(chr(b) for b in response)
                    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    self.log_status_if_changed(status_updates, "Active", version, current_time)

                    time.sleep(5)

                except usb.core.USBError as e:
                    self.log_status_if_changed(status_updates, "Inactive - USB Error", None, None)
                    break 

            usb.util.dispose_resources(self.dev)
            self.log_status_if_changed({}, "Waiting 10 seconds before reconnecting...", None, None)
            time.sleep(10)

class CashRecyclerPeripheral(PeripheralMonitor):
    def __init__(self, queue, device_name, command):
        super().__init__(queue, device_name)
        self.command = command
        self.exe_path = os.path.join(os.path.dirname(__file__), "test_terminal/test_terminal.exe")

    def start_monitoring(self, status_updates):
        self.log_status_if_changed({}, "Monitoring started", None, None)
        last_response = None

        while self.running and not shutdown_flag:
            try:
                result = subprocess.run([self.exe_path, "-c", self.command], capture_output=True, text=True)

                if result.stderr:
                    self.queue.put((self.device_name, 'error', f"Error executing command: {result.stderr.strip()}"))

                if result.stdout != last_response:  
                    self.log_status_if_changed(status_updates, result.stdout.strip(), None, None)
                    last_response = result.stdout.strip()

                response = result.stdout.strip().split('\n')[-1] 
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                self.log_status_if_changed(status_updates, "Active", response, current_time)

            except Exception as e:
                self.queue.put((self.device_name, 'error', f"Error executing terminal command: {e}"))
                self.log_status_if_changed(status_updates, f"Error executing command: {e}", None, current_time)

            time.sleep(5)

def monitor_peripheral(monitor: PeripheralMonitor, status_updates):
    if isinstance(monitor, USBPeripheral):
        monitor.monitor(status_updates)
    elif isinstance(monitor, SerialPeripheral):
        monitor.monitor(status_updates)
    elif isinstance(monitor, CashRecyclerPeripheral):
        monitor.start_monitoring(status_updates)

def draw_menu(devices, status_updates):
    console = Console()
    while not shutdown_flag:
        table = Table(title="Peripheral Status", caption="Last updated every second")
        table.add_column("Device Name", style="cyan")
        table.add_column("Status", style="magenta")
        table.add_column("Last Response", style="green")
        table.add_column("Last Sent", style="yellow")

        for device in devices:
            status = status_updates.get(device.device_name, {})
            table.add_row(
                device.device_name,
                status.get('status', 'Unknown'),
                status.get('last_data', 'None'),
                status.get('last_sent', 'None')
            )

        console.clear()
        console.print(table)
        time.sleep(1)
        
def start_menu(devices, status_updates):
    draw_menu(devices, status_updates)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)  

    manager = Manager()
    status_updates = manager.dict()
    queue = Queue()

    log_process = Process(target=log_manager, args=(queue,))
    log_process.start()

    devices = [
        SerialPeripheral(queue, "Antiskimming", "COM1"),
        SerialPeripheral(queue, "Sensor_board", "COM13"),
        SerialPeripheral(queue, "Check_scanner", "COM26"),
        USBPeripheral(queue, "Thermal_Printer"),
        CashRecyclerPeripheral(queue, "Cash_Recycler", "e011")
    ]

    menu_process = Process(target=start_menu, args=(devices, status_updates))
    menu_process.start()

    processes = []
    for device in devices:
        p = Process(target=monitor_peripheral, args=(device, status_updates))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()

    queue.put(None)  
    log_process.join()  
    menu_process.join()  
