import sys
import serial

def send_command_to_printer(port, command):
    try:
        ser = serial.Serial(
            port,
            115200
        )
        ser.write(command.encode())
        response = ser.read(100)
        ser.close()
        print(f"Response from printer: {response}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python printer_script.py <COM_PORT> <COMMAND> <ARGS>")
    else:
        port = sys.argv[1]
        command = sys.argv[2]

        send_command_to_printer(port, command, )
