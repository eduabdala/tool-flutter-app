import sys
import serial

def send_command_to_printer(port, baud_rate, command):
    try:
        ser = serial.Serial(
            port,
            baudrate=baud_rate,
        )
        ser.write(command.encode())
        response = ser.read(100)
        ser.close()
        print(f"Response from printer: {response}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 7:
        print("Usage: python printer_script.py <COM_PORT> <BAUD_RATE> <COMMAND>")
    else:
        port = sys.argv[1]
        baud_rate = int(sys.argv[2])
        command = sys.argv[3]

        send_command_to_printer(port, baud_rate, command)
