import usb.core
import usb.util
import time
import argparse
import sys  # Importando sys para usar sys.exit()

# Definindo o VID e PID
vid = 0x1abd
pid = 0x0001

# Função para conectar ao dispositivo USB
def connect_device():
    dev = usb.core.find(idVendor=vid, idProduct=pid)
    if dev is None:
        print("Inactive - Device Not Found")
        return None
    
    dev.set_configuration()
    cfg = dev.get_active_configuration()
    intf = cfg[(0, 0)]

    ep_out = usb.util.find_descriptor(
        intf,
        custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_OUT
    )
    ep_in = usb.util.find_descriptor(
        intf,
        custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_IN
    )
    return dev, ep_out, ep_in

# Função para enviar e opcionalmente esperar a resposta
def send_command(command, wait_for_response):
    """Envie um comando para o dispositivo USB com ou sem esperar resposta"""
    dev, ep_out, ep_in = connect_device()
    if dev is None:
        return "Device not found", 1  # Retorna 1 para erro

    try:
        # Envia o comando
        ep_out.write(command)
        
        if wait_for_response:
            # Aumentando o tempo de espera para a resposta
            timeout = 10000  # Tempo de espera de 10 segundos
            response = ep_in.read(8, timeout=timeout)  # Passando o timeout

            if len(response) == 0:
                return "No data received", 1  # Retorna 1 para erro
            
            # Converte a resposta de bytes para string
            version = ''.join(chr(b) for b in response)
            current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            
            return {"version": version, "time": current_time}, 0  # Retorna 0 para sucesso
        
        return "Command sent successfully, no response awaited.", 0  # Retorna 0 para sucesso
    
    except usb.core.USBError as e:
        return f"USB error: {e}", 1  # Retorna 1 para erro
    
    except Exception as e:
        return f"Unexpected error: {e}", 1  # Retorna 1 para erro
    
    finally:
        usb.util.dispose_resources(dev)

# Função principal para lidar com os argumentos da linha de comando
def main():
    parser = argparse.ArgumentParser(description="Send a command to the USB device and optionally wait for a response.")
    
    # Adicionando opções para o formato do comando
    parser.add_argument("command", type=str, help="The command to send to the USB device.")
    parser.add_argument("-x", "--hex", action="store_true", help="Interpret the command as hexadecimal.")
    parser.add_argument("-d", "--dec", action="store_true", help="Interpret the command as decimal.")
    parser.add_argument("-a", "--ascii", action="store_true", help="Interpret the command as ASCII.")
    parser.add_argument("-w", "--wait", action="store_true", help="Wait for a response after sending the command.")
    
    # Parse os argumentos
    args = parser.parse_args()

    # Determinando qual formato o comando estará
    try:
        if args.hex:
            # Comando em formato hexadecimal
            command = bytes.fromhex(args.command)
        elif args.dec:
            # Comando em formato decimal, separados por espaços
            command = bytes([int(x) for x in args.command.split()])
        elif args.ascii:
            # Comando em formato ASCII (string para bytes)
            command = args.command.encode('utf-8')

        else:
            print("Please specify a format: -x (hex), -d (dec), or -a (ascii)")
            sys.exit(1)  # Retorna 1 (erro) se nenhum formato for especificado
    except ValueError:
        print("Invalid command format. Ensure the input matches the expected format.")
        sys.exit(1)  # Retorna 1 (erro) se o formato do comando for inválido
    
    # Envia o comando e decide se deve esperar ou não pela resposta
    result, exit_code = send_command(command, args.wait)
    
    # Exibe o resultado
    if isinstance(result, dict):
        print(f"Version: {result['version']}, Time: {result['time']}")
    else:
        # Trata a situação de não retorno de dados ou erro
        print(result)
    
    # Retorna o código de status (0 para sucesso, 1 para falha)
    sys.exit(exit_code)

# Executando o script
if __name__ == "__main__":
    main()
