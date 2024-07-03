import serial
import serial.tools.list_ports

def conectar_auto():
    try:
        print("Iniciando a busca por portas COM...")
        ports = list(serial.tools.list_ports.comports())
        if not ports:
            print("Nenhuma porta COM disponível")
            return "Nenhuma porta COM disponível"
        
        # Filtra para remover a porta COM1
        ports = [port for port in ports if port.device != 'COM1']
        
        if not ports:
            print("Nenhuma porta COM disponível (exceto COM1)")
            return "Nenhuma porta COM disponível (exceto COM1)"
        
        port = ports[0].device
        print(f"Tentando conectar na porta {port}...")
        ser = serial.Serial(port, 9600, timeout=1)
        
        if ser.is_open:
            print(f"Conectado com sucesso na porta {port}")
            ser.close()
            return f"Conectado com sucesso na porta {port}"
        
        return "Falha ao abrir a porta"
    
    except serial.SerialException as e:
        print(f"Falha ao conectar: {e}")
        return f"Falha ao conectar: {e}"

if __name__ == "__main__":
    resultado = conectar_auto()
    print(resultado)
