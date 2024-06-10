import json
import serial



def load_serial_config(file_path):
    with open(file_path, 'r') as f:
        config = json.load(f)
        return config

def setup_serial_port(config):
    port = config['port']
    baud_rate = int(config['baudRate'])
    ser = serial.Serial(port, baud_rate)
    return ser

if __name__ == "__main__":
    config = load_serial_config('serial_config.json')
    serial_port = setup_serial_port(config)
    print(f'Porta Serial {serial_port.portstr} configurada com baud rate {serial_port.baudrate}')
