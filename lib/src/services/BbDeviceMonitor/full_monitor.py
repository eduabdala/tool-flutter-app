import json
import logging
import os
import time
import usb.core
import usb.util
import serial
import subprocess
from multiprocessing import Process

def setup_logging(device_name: str, port: str):
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logger = logging.getLogger(f"{device_name}_{port}")
    if not logger.hasHandlers():
        logger.setLevel(logging.INFO)

        handler = logging.FileHandler(f'{log_dir}/logs_{device_name}_{port}.log')
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)

        json_handler = logging.FileHandler(f'{log_dir}/errors_{device_name}_{port}.log')
        json_handler.setLevel(logging.ERROR)
        logger.addHandler(json_handler)

    return logger

class PeripheralMonitor:
    def __init__(self, logger: logging.Logger):
        self.logger = logger
        self.status = "Idle"
        self.running = True

    def start_monitoring(self):
        self.status = "Monitoring"
        self.logger.info("Starting monitoring...")

    def stop_monitoring(self):
        self.status = "Stopped"
        self.logger.info("Monitoring stopped.")
        self.running = False

    def get_status(self):
        return self.status

    def log_status(self, device_name, status, last_data, last_send):
        log_message = f"Device: {device_name} | Status: {status} | Last Data: {last_data or 'None'} | Last Send: {last_send}"
        self.logger.info(log_message)

class SerialPeripheral(PeripheralMonitor):
    def __init__(self, logger: logging.Logger, port: str, device: str):
        super().__init__(logger)
        self.port = port
        self.device_name = device
        self.baud_rate = 115200
        self.timeout = 5
        self.cmd_pd = b'\x02V\x03W'
        self.ser = None

    def connect(self):
        try:
            self.ser = serial.Serial(self.port, baudrate=self.baud_rate, timeout=self.timeout)
            self.logger.info(f"Connected to {self.device_name} on port {self.port}")
        except serial.SerialException as e:
            self.logger.error(f"Failed to connect to {self.port}: {e}")
            self.ser = None

    def reconnect(self):
        self.logger.info(f"Trying to reconnect {self.device_name} on port {self.port}")
        self.connect()

    def monitor(self):
        self.connect()

        while self.running:
            if not self.ser:
                self.logger.warning(f"Failed to connect to {self.device_name} on {self.port}.")
                self.log_status(self.device_name, "Inactive - Connection Failed", None, None)
                time.sleep(5)
                self.reconnect()
                continue

            try:
                self.ser.write(self.cmd_pd)
                self.logger.info(f"Sent command packet to {self.device_name} on {self.port}: {self.cmd_pd}")

                response = self.ser.readline()

                if response:
                    self.logger.info(f"Raw response received: {response}")
                    resp_data = response[2:-1].decode('utf-8', errors='ignore')
                    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    self.log_status(self.device_name, "Active", resp_data, current_time)
                else:
                    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    self.logger.warning(f"{self.device_name} on {self.port} - No data received")
                    self.log_status(self.device_name, "Inactive - No Data", None, current_time)

            except Exception as e:
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                error_message = f"Error during communication: {e}"
                self.logger.error(error_message)
                self.log_status(self.device_name, error_message, None, current_time)
                if self.ser:
                    self.ser.close()
                self.reconnect()

            time.sleep(5)

    def stop(self):
        self.running = False
        if self.ser:
            self.ser.close()
            self.logger.info(f"Connection to {self.device_name} on {self.port} closed.")

class USBPeripheral(PeripheralMonitor):
    vid = 0x1abd
    pid = 0x0001 

    def __init__(self, logger: logging.Logger):
        super().__init__(logger)
        self.dev = None
        self.intf = None
        self.ep_out = None
        self.ep_in = None

    def connect_device(self):
        self.logger.info("Attempting to connect to the device...")
        self.dev = usb.core.find(idVendor=self.vid, idProduct=self.pid)
        if self.dev is None:
            raise ValueError(f"Device: Thermal Printer | Status: Device not found | Last Data: 'None' ")

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

        self.logger.info("Device connected successfully.")

    def monitor(self):
        while self.running:
            try:
                self.connect_device()
            except ValueError as e:
                self.logger.error(e)
                self.logger.info("Waiting 10 seconds before trying to reconnect...")
                time.sleep(10)
                continue

            version_command = bytes([0x1b, 0x1a, 0x08, 0x43])  

            while self.get_status() == "Monitoring":
                try:
                    self.logger.info(f"Executing command: {self.ep_out.write(version_command)}")
                    time.sleep(0.1)  

                    response = self.ep_in.read(8)

                    if len(response) == 0:
                        self.logger.warning("Empty response received. Reconnecting...")
                        self.log_status("USB Printer", "Inactive - No Data", None, None)
                        break  

                    version = ''.join(chr(b) for b in response)
                    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    self.log_status("USB Printer", "Active", version, current_time)

                    time.sleep(5)

                except usb.core.USBError as e:
                    self.logger.error(f"USB Error: {e}")
                    self.log_status("USB Printer", "Inactive - USB Error", None, None)
                    break 

            usb.util.dispose_resources(self.dev)
            self.logger.info("Waiting 10 seconds before reconnecting...")
            time.sleep(10)

class CashRecyclerPeripheral(PeripheralMonitor):
    def __init__(self, logger: logging.Logger, command: str):
        super().__init__(logger)
        self.command = command
        self.exe_path = os.path.join(os.path.dirname(__file__), "test_terminal/test_terminal.exe")

    def start_monitoring(self):
        super().start_monitoring()
        last_response = None

        while self.get_status() == "Monitoring":
            try:
                self.logger.info(f"Executing command: {self.command}")
                result = subprocess.run([self.exe_path, "-c", self.command], capture_output=True, text=True)
                current_response = result.stdout.strip() 

                if result.stderr:
                    self.logger.error(f"Error: {result.stderr.strip()}")

                if current_response != last_response:  
                    self.logger.info(f"Command output: {current_response}")
                    last_response = current_response

                response = current_response.strip().split('\n')[-1] 
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                self.log_status("Cash Recycler", "Active", response, current_time)

            except Exception as e:
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                error_message = f"Error executing terminal command: {e}"
                self.logger.error(error_message)
                self.log_status("Cash Recycler", error_message, None, current_time)

            time.sleep(5)

def monitor_peripheral(monitor: PeripheralMonitor):
    if isinstance(monitor, USBPeripheral):
        monitor.monitor()
    elif isinstance(monitor, SerialPeripheral):
        monitor.monitor()
    elif isinstance(monitor, CashRecyclerPeripheral):
        monitor.start_monitoring()

if __name__ == "__main__":
    devices = [
        SerialPeripheral(setup_logging("Antiskimming", "COM1"), "COM1", "Antiskimming"),
        SerialPeripheral(setup_logging("Sensor_board", "COM99"), "COM99", "Sensor_board"),
        SerialPeripheral(setup_logging("Check_scanner", "COM99"), "COM99", "Check_scanner"),
        USBPeripheral(setup_logging("Thermal_printer", " ")),
        CashRecyclerPeripheral(setup_logging("Cash_recycler", " "), "e011")
    ]

    processes = []
    for device in devices:
        p = Process(target=monitor_peripheral, args=(device,))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()
