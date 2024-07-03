import serial

def connect_serial(port='COM24', baudrate=115200):
    try:
        ser = serial.Serial(port, baudrate, timeout=1)
        print(f"Conectado na porta {port} com baudrate {baudrate}")
        return ser
    except serial.serialutil.SerialException as e:
        print(f"Erro ao conectar: {e}")
        return None

def main():
    ser = connect_serial()
    if ser:
        try:
            while True:
                if ser.in_waiting > 0:
                    data = ser.readline().decode('utf-8').rstrip()
                    print(f"Recebido: {data}")
        except KeyboardInterrupt:
            print("Fechando conexão...")
        finally:
            ser.close()
            print("Conexão fechada.")

if __name__ == '__main__':
    main()
