import serial
import time
import logging
import signal
import json
import os
import serial.tools.list_ports

running = True
device_status = {}

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def cmd_pd(command):
    full_command = "\x02" + command + "\x03"
    bcc = calculate_bcc(full_command)
    full_command_with_bcc = full_command.encode('utf-8') + bcc
    return full_command_with_bcc

def calculate_bcc(command):
    bcc = 0
    for char in command:
        bcc ^= ord(char)
    return bytes([bcc]) 

def setup_logging(device_name, port):
    logger = logging.getLogger(f"{device_name}_{port}")
    if not logger.hasHandlers():
        logger.setLevel(logging.INFO)
        
        handler = logging.FileHandler(f'logs_{device_name}_{port}.log')
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)

        json_handler = logging.FileHandler(f'errors_{device_name}_{port}.json')
        json_handler.setLevel(logging.ERROR)
        logger.addHandler(json_handler)
    
    return logger

def log_error(device_name, port, error_message):
    error_data = {
        "device_name": device_name,
        "port": port,
        "error": str(error_message),  
        "timestamp": time.time()
    }
    with open(f'errors_{device_name}_{port}.json', 'a') as json_file:
        json.dump(error_data, json_file)
        json_file.write('\n')  

def log_stop_event(device_name, port):
    logger = logging.getLogger(f"{device_name}_{port}")
    logger.info(f"Monitoring stopped for {device_name} on {port}")

def connect_device(device_name, port, baud_rate=115200, timeout=5):
    logger = setup_logging(device_name, port)
    try:
        ser = serial.Serial(port, baudrate=baud_rate, timeout=timeout)
        logger.info(f"Connected to {device_name} on port {port}")
        return ser
    except serial.SerialException as e:
        logger.error(f"Failed to connect to {port}: {e}")
        return None

def reconnect_device(device_name, port, baud_rate=115200, timeout=5):
    logger = setup_logging(device_name, port)
    logger.info(f"Trying to reconnect {device_name} on port {port}")
    ser = connect_device(device_name, port, baud_rate, timeout)
    if ser:
        return ser

def monitor_peripheral(device_name, port):
    global device_status  
    last_status = None 
    logger = setup_logging(device_name, port)

    ser = connect_device(device_name, port)

    while running:
        if not ser:

            logger.warning(f"Failed to connect to {device_name} on {port}.")
            status = {"device_name": device_name, "port": port, "status": "Inactive - Connection Failed", "last_data": None, "last_send": None}
            device_status[device_name] = status
            
            if status != last_status:
                last_status = status.copy()
                yield status
            
            time.sleep(5) 
            ser = reconnect_device(device_name, port)
            continue
        
        try:
            command = 'V'   
            command_packet = cmd_pd(command)
            ser.write(command_packet)
            logger.info(f"Sent command packet to {device_name} on {port}: {command_packet}")

            response = ser.readline()  

            if response:
                logger.info(f"Raw response received: {response}")
                cmd = response[1] if len(response) > 1 else None  
                resp_data = response[2:-1]  
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                status = {"device_name": device_name, "port": port, "status": "Active", "last_data": resp_data.decode('utf-8', errors='ignore'), "last_send": current_time}
            else:
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                logger.warning(f"{device_name} on {port} - No data received")
                status = {"device_name": device_name, "port": port, "status": "Inactive - No Data", "last_data": None, "last_send": current_time}

        except Exception as e:
            current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            error_message = f"Error during communication: {e}"
            logger.error(error_message)
            log_error(device_name, port, error_message)
            status = {"device_name": device_name, "port": port, "status": error_message, "last_data": None, "last_send": current_time}
            ser.close()
            ser = reconnect_device(device_name, port)

        device_status[device_name] = status  

        if status != last_status:
            last_status = status.copy()
            yield status
            
        time.sleep(5) 

def display_peripheral_status(device_ports):
    status_generators = {}

    for device_name, port in device_ports.items():
        status_generators[device_name] = monitor_peripheral(device_name, port)

    while running:
        status_lines = []
        for device_name, gen in list(status_generators.items()):  
            try:
                status = next(gen)
                status_line = f"Device: {device_name} | Port: {status['port']} | Status: {status['status']} | Last Data: {status['last_data'] or 'None'} | Last Send: {status['last_send']}"
                status_lines.append(status_line) 

            except StopIteration:
                status_line = f"Device: {device_name} | Status: Stopped monitoring."
                status_lines.append(status_line)
                del status_generators[device_name] 

        clear_screen() 
        print("\n".join(status_lines))  

def signal_handler(sig, frame):
    global running
    print("\nTerminating monitoring...")
    for device_name, port in device_ports.items():
        log_stop_event(device_name, port)
    running = False 

def listar_portas():
    portas = serial.tools.list_ports.comports()
    return [port.device for port in portas]

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    print("Available ports:")
    available_ports = listar_portas() 
    for idx, port in enumerate(available_ports):
        print(f"{idx + 1}: {port}")
    
    device_ports = {}
    while True:
        device_name = input("Write device name (or 'ok' to start monitoring): ")
        if device_name.lower() == 'ok':
            break
        
        port = input(f"Choose the port for {device_name} (enter the number): ")
        try:
            selected_port = available_ports[int(port) - 1]
            device_ports[device_name] = selected_port
        except (IndexError, ValueError):
            print("Invalid port number. Please try again.")

    try:
        display_peripheral_status(device_ports)
    except Exception as e:
        logging.error(f"An error occurred: {e}")