import json
import subprocess
from robot.api.deco import keyword
import logger
import datehandler
import unittest
import datetime
from api import pertoapi, pertorelayapi1, pertoenv, Logger
from remember import remember_table_get
from robot.api import logger
from time import sleep as wait_second
import re
import tkinter as tk
from tkinter import messagebox

### Dictionaries ###

answer_success = "000"
errors_dictionary = {'001': 'Falha na execução do comando','002': 'Comando não pode ser executado porque o canal de comunicação está ocupado',
'003': 'Timeout na execução do comando', '004': 'Erro na execução do comando', '005': 'Comando existe mas está desabilitado', '010': 'Erro de tamper', '012': 'Erro no comando de calibração'}

def send_command_to_antiskimming(cmd):
    pertoapi.cmd(cmd)
    return pertoapi.then.send().decode("unicode-escape")
def send_command_to_relay(cmd):
    pertorelayapi1.cmd(cmd)
    return pertorelayapi1.then.send().decode("unicode-escape")

@keyword("Eu recebo o aviso '${mensagens}'")
def exibir_mensagem(mensagens):
    root = tk.Tk()
    root.withdraw()
    result = messagebox.askokcancel("Aviso", f"\n{mensagens}")
    if result:
        return "O usuário pressionou OK"
    else:
        raise Exception(f"O usuário pressionou Cancelar")
    root.destroy()

def get_com_port(info):
    """
    Finds the COM port associated with a specific USB device.

    Parameters:
        info (str): Information about the USB device (e.g., "VID_1ABD&PID_00A0").

    Returns:
        str: The COM port associated with the USB device, or one of the following error codes:
            - "-1": COM port not found for the specified device.
            - "-2": Error executing PowerShell.
            - "-3": No matching USB device found.
    """
    
    powershell_script = f"""
    $Info = "{info}"
    $usbDevices = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object {{ $_.DeviceID -like 'USB*' }}
    if ($usbDevices -eq $null -or $usbDevices.Count -eq 0) {{
        Write-Output "-3"
    }} else {{
        foreach ($device in $usbDevices) {{
            if ($device.DeviceID -like "*$Info*") {{
                $comPort = Get-CimInstance -ClassName Win32_SerialPort | Where-Object {{ $_.PNPDeviceID -eq $device.PNPDeviceID }}
                if ($comPort) {{
                    Write-Output "$($comPort.DeviceID)"
                }} else {{
                    Write-Output "-1"
                }}
            }}
        }}
    }}
    """
    process = subprocess.Popen(['powershell', '-Command', powershell_script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if stderr:
        return "-2"
    output = stdout.decode('latin-1').strip().split('\n')
    for line in output:
        if line.strip() and line.strip() not in ["-1", "-3"]:
            return line.strip()
        elif line.strip() == "-1":
            return "-1"
    return "-3"


@keyword("Eu configuro a porta serial")
def pipeline_serial_port(info="VID_1ABD&PID_00A0"):
    pertoapi.setInterface.serial ('port',get_com_port(info)) 
    pertorelayapi1.setInterface.serial('port', pertoenv.PORT_RELAY)

@keyword("Comando '${xpto}'")
def perto_get_command(xpto):
    command = remember_table_get(xpto, 'comando')
    return (command.decode('utf-8') if command != xpto else xpto)

@keyword("Eu configuro o log da serial")
def pipeline_serial_log():
    current_time = datehandler.get_time(format="%Y_%m_%d_%H_%M_%S")
    pertoapi.setInterface.logger(Logger("sensor_board_log",
    f"{pertoenv.log_folder}/log_sensor_board_{current_time}",
    start_logging_on_creation=True))

@keyword("variavel de ambiente {${xpto}}")
def perto_env_get(xpto):
    return getattr(pertoenv, xpto)

@keyword("variavel de ambiente opcional {${xpto}}")
def perto_env_get_non_fail(xpto):
    try:
        return getattr(pertoenv, xpto)
    except KeyError:
        return ''

@keyword("busco {${tree_nodes}} no arquivo json {${path}}")
def perto_json_get(tree_nodes, path):
    with open(path, 'r', encoding="utf-8") as file:
        objeto_python = json.load(file)
    val_var = objeto_python
    for key in tree_nodes:
        val_var = val_var[key]
    return val_var

@keyword("Eu aguardo '${time}' segundos")
def pipeline_time(time):
    time=int(time)
    logger.console("\nAguarde...")
    dots = ""
    for i in range(time):
        rest= time -i
        dots += "."
        logger.console(dots)
        wait_second(1)

@keyword("Eu atualizo o firmware")
def update_firmware():
    logger.console("Atualizando firmware...")
    firmware = perto_json_get(["firmware","iversion"], perto_env_get("PATH_ETE"))
    output_folder = perto_env_get("UPDATE_OUTPUT_PATH")
    with open(f"{output_folder}update_output.txt", 'w', encoding="utf-8") as update_output_file:
        process = subprocess.run(["updt_cmd.exe", "-s", "-d4",
                                  pertoenv.PORT,
                                  f"{output_folder}{firmware}.fir"],
                                  stdout=update_output_file,
                                  check=False)
    if process.returncode == 5:
        logger.console("Firmware atualizado com sucesso!")
    else:
        raise Exception("Falha na atualização do firmware!")

@keyword("Eu verifico se a versão comercial de firmware está correta")
def robot_check_firmware_version():
    """
    Verifica se a versão comercial de firmware está correta

    Exemplo:
        | Keyword                                                    | Retorno   |
        | Eu verifico se a versão comercial de firmware está correta | VF1584C10 |
    """
    answer = send_command_to_antiskimming("V")
    expected_answer="V" + str(perto_json_get(["firmware","version"], perto_env_get("PATH_ETE")))
    if answer!= expected_answer:
        raise Exception(f"Esperada a versão comercial conforme: '{expected_answer}' mas foi obtida: '{answer}'")
    return (answer)


@keyword("Eu verifico a versão de repositório")
def check_repository_version():
    """
    Verifica se a versão da revisão do Git está correta

    Exemplo:
        | Keyword                                     | Retorno                    |
        | Eu verifico se a versão do GIT está correta | i|v1.1.0|482|ee4ea694 |
    """
    path_pipeline_json = "../doc/ETE/Skeleton/common/pipeline.json"
    answer = send_command_to_antiskimming("ig")
    expected_answer = "i|"+str(perto_json_get(["RELEASE_TAG"], path_pipeline_json))
    expected_answer += "|"+str(perto_json_get(["PIPELINE_IID"], path_pipeline_json)) 
    expected_answer += "|" + str(perto_json_get(["COMMIT_HASH"], path_pipeline_json))
    if answer!= expected_answer:
        raise Exception(f"Esperada a versão de repositório conforme: '{expected_answer}' mas foi obtida: '{answer}'")
    return (expected_answer)

@keyword("Eu verifico a versão completa de firmware") 
def check_complete_version():
    """
    Verifica se a versão completa do firmware está correta

    Exemplo:
        | Keyword                                                   |Retorno                   |
        | Eu verifico se a versão completa do firmware está correta |i<FA3SUA03><FA3SUA03><482>|
    """
    path_pipeline_json = "../doc/ETE/Skeleton/common/pipeline.json"
    answer = send_command_to_antiskimming("ip")
    expected_answer = "i<"+str(perto_json_get(["firmware","version"], perto_env_get("PATH_ETE")))+">"
    expected_answer += "<"+str(perto_json_get(["firmware","iversion"], perto_env_get("PATH_ETE")))+">" 
    expected_answer += "<" + str(perto_json_get(["PIPELINE_IID"], path_pipeline_json))+">"
    if answer != expected_answer:
        raise Exception(f"Esperada a versão de repositório conforme: '{expected_answer}' mas foi obtida: '{answer}'")
    return (expected_answer)
        

@keyword("Eu verifico se o status de violação do sensor '${sensor}' é '${state}'")
def check_sensor_violation_status(sensor,state):
    """
    Verifica se os status de violação do sensor recebido coincide com o esperado
    Args:
        state: estado esperado (Ausente, Suspeita, Detectado)
    Exemplo:
        | Keyword                                                              |
        | Eu verifico se o status de violação do sensor 'Tamper' é 'Detectado' |
    """
    sensors_names = ["Antiskimming","Tamper", "Jammer", "Sensor Nulo 1", "Sensor Nulo 2", "Sensor Nulo 3", "Sensor Nulo 4", "Sensor Nulo 5", "Capacitivo Externo", "Capacitivo Interno", "Sensor Nulo 10", "Sensor Nulo 11", "Sensor Nulo 12", "Sensor Nulo 13"]
    states_dictionary = {'1': 'Detectado','D': 'Detectado','S': 'Suspeita','A': 'Ausente','0': 'Ausente'}
    answer = send_command_to_antiskimming("S")
    fields = answer.split('|')
    sensors_state = fields[1] + fields[2] + fields[3]
    dictionary=({sensors_names[i]: sensors_state[i] for i in range(len(sensors_names))})
    sensor_state = dictionary.get(sensor, "Não disponível")
    sensor_state = states_dictionary.get(sensor_state, "Não disponível")
    if sensor_state != state:
        raise Exception(f"Esperado '{state}' mas o estado é '{sensor_state}' para o sensor '{sensor}'")
    return (answer)           

@keyword("Eu solicito que o usuário altere o '${sensor}' para o estado '${state}' com timeout de '${timeout}' segundos")
def request_state_change(sensor,state,timeout):
    """
        | NÃO UTULIZADO |
        | Mas é uma keyword utilizada para interação humana|
    """
    i=0
    timeout=int(timeout)
    while i<timeout:
        logger.console(f"Altere o estado de '{sensor}' para o estado '{state}' com timeout em '{timeout-i}' segundos")
        try:
            check_sensor_violation_status(sensor,state)
            break
        except:
            pass
        wait_second(1)
        i+=1
    if(i == timeout):
        raise Exception(f"Estado de '{sensor}' não foi alterado para o estado '{state}'")

@keyword("Eu realizo a calibração e espero '${state}'")
def calibrate_sensors(state="000"):
    """
    Para calibrar o antiskimming quando estiver no estado de (Ausente, Suspeita ou Detectado)
    Exemplo:
        | Keyword                                |
        | Eu realizo a calibração e espero '000' |
    """
    
    print(calibrate("C",state))
    return(calibrate("C",state))

@keyword("Eu limpo o estado de todas as violações e zonas e espero '${state}'")
def clean_violation_flags(state):
    return(calibrate(">",state))

def calibrate(command,state):
    answer = send_command_to_antiskimming(command)[1:]
    aux= errors_dictionary.get(answer,"Não disponível")
    if answer != state:
        raise Exception(f"Erro na calibração: '{aux}'")
    return(aux)

@keyword("Eu verifico se a flag de proteção contra violação está '${state}'")
def check_violation_flags(state):
    dictionary = {'ativa': '1000','inativa': '0000'}
    answer = send_command_to_antiskimming("F")[1:]
    state = dictionary.get(state,"Não disponível")
    if answer != state:
        answer= dict(zip(dictionary.values(), dictionary.keys())).get(answer,"Não disponível")
        raise Exception(f"Flags de violação: '{answer}'")
    return (answer)

@keyword("Eu aplico reset na leitora")
def clean_reset_flags():
    return(reset(b'_'))
def reset(command):
    answer = send_command_to_antiskimming(command)[1:]
    aux= errors_dictionary.get(answer, "012")
    if answer == answer_success:
        raise Exception(f"Erro na calibração: '{aux}'")
    return(answer)

@keyword("Retorna a quantidade total de eventos")
def check_eventos():
    answer = send_command_to_antiskimming("m")[1:]
    if int(answer) < 0 :
        raise Exception(f"")
    return answer

@keyword("Retorna o estado atual do sensor do sistema Antiskimming")
def check_current_system():
    answer = send_command_to_antiskimming("W")[1:]
    if str.isalnum (answer) == answer :
        raise Exception(f"Falha na consulta ({answer}).")
    return answer

@keyword("Eu verifico a data e hora")
def date_verify():
    s = send_command_to_antiskimming(":")[1:]
    hora, minuto, segundo, dia, mes, ano = map(int, (s[1:3], s[4:6], s[7:9], s[11:13], s[14:16], s[17:19]))
    if (0 <= hora <= 23 and 0 <= minuto <= 59 and 0 <= segundo <= 59 and
        1 <= dia <= 31 and 1 <= mes <= 12 and 0 <= ano <= 99):
        return (s)
    raise Exception(f"Formato inválido: '{s}'")

@keyword("Configurar data e hora para '${data}' e espero '${resultado}'")
def date_and_hour_set(dt,resultado):
    date, time = dt.split("T")
    year, month, day = date.split("-")
    hour, minute, second = time.split(":")
    second = second.split(".")[0]  # Removendo os microssegundos
    custom_format = hour + minute + second + day + month + year[2:]
    st = "J"+ custom_format
    answer = send_command_to_antiskimming(st)[1:]
    if answer != resultado:
       raise Exception(f"Falha na data e hora. {answer}") 
    return (f"{answer}")

@keyword("Data e hora atuais")
def adjust_date_and_time():
    now = datetime.datetime.now()
    dt = now.strftime("%H%M%S%d%m%y")
    st = "J" + dt
    answer = send_command_to_antiskimming(st)[1:]
    if answer != answer :
       raise Exception(f"Falha na data e hora. {answer}") 
    return answer

@keyword("Configura o tempo para detecção de fraude '${valor}' e espero '${resultado}'")
def detection_fraud_time_set(valor, resultado):
    ts = "s"+ str(valor)
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Falha no valor. {answer}") 
    return (f"{answer}")

@keyword("Configura o tempo para normalização de fraude '${valor}' e espero '${resultado}'")
def nomarlization_fraud_time_set(valor, resultado):
    ts = "@"+ str(valor)
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Falha no valor. {answer}") 
    return (f"{answer}")

@keyword("Eu defino o estado do relé '${relay}' para '${state}'")
def set_relay_state(relay,state):
    answer = send_command_to_relay("K"+relay+state)
    if answer != ("K"+relay+state+"000"):
       raise Exception(f"Falha no valor. {answer}") 

@keyword("Eu verifico que o estado do relé '${relay}' é '${value}'")
def check_relay_status(relay, value):
    answer = send_command_to_relay("O")[1:]
    relay_values = []
    for j, grupo in enumerate(answer):
        if j in (10, 12, 18, 19):
            relay_values.append(int(grupo))
        else:
            relay_values.extend([int(c) for c in grupo])
    lista = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    dictionary = {elemento: relay for relay, elemento in enumerate(lista)}
    if relay not in lista:
        raise ValueError(f"Número de relé inválido: '{relay}'")
    if value not in ("0", "1"):
        raise ValueError(f"Valor de estado inválido: '{value}'. O valor deve ser '0' ou '1'.")
    relay_index = dictionary.get(relay, len(lista))
    relay_status = str(relay_values[relay_index])
    if relay_status != value:
        raise Exception(f"Esperado '{value}' mas o valor é '{relay_status}' para o relé '{relay}'")
    return relay_status

@keyword("Eu verifico que o estado da entrada '${input}' é '${value}'")
def check_input_status(input, value):
    answer = send_command_to_relay("I")[1:]
    input_values = []
    for j, grupo in enumerate(answer):
        if j in (10, 12, 18, 19):
            input_values.append(int(grupo))
        else:
            input_values.extend([int(c) for c in grupo])
    lista = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    dictionary = {elemento: input for input, elemento in enumerate(lista)}
    if input not in lista:
        raise ValueError(f"Número da entrada inválida: '{input}'")
    if value not in ("0", "1"):
        raise ValueError(f"Valor de estado inválido: '{value}'. O valor deve ser '0' ou '1'.")
    input_index = dictionary.get(input, len(lista))
    input_status = str(input_values[input_index])
    if input_status != value:
        raise Exception(f"Esperado '{value}' mas o valor é '{input_status}' para a entrada '{input}'")
    return input_status

@keyword("Eu seleciono a zona '${valor}' e espero '${resultado}'")
def select_the_zone(valor, resultado):
    ts = "K"+ str(valor)
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Falha no valor. {answer}") 
    return ({answer})

@keyword("Eu seleciono o sensor '${valor}' e espero '${resultado}'")
def select_zone(valor, resultado):
    ts = "c"+ str(valor)
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Falha no valor. {answer}") 
    return ({answer})

@keyword("Checar se o sensor '${sensor}' está '${state}'")
def check_sensor_presence(sensor, state):
    with open(pertoenv.PATH_CONFIG, 'r') as arquivo:
        config = json.load(arquivo)
    sensor_path = sensor.split('.')
    value = config
    for key in sensor_path:
        value = value.get(key)
    return value is (state == "desabilitado")

@keyword("Retorna os tempos de detecção e de normalização")
def detection_times():
    answer = send_command_to_antiskimming("!")[1:]
    if str.isalnum (answer) == answer :
        raise Exception(f"Falha na consulta ({answer}).")
    return answer
    
@keyword("Verifica se os tempos de detecção e de normalização são '${expected}'")
def detection_expected_times(expected):
    answer = send_command_to_antiskimming("!")[1:]
    if str.isalnum (answer) == answer :
        raise Exception(f"Falha na consulta ({answer}).")
    if (answer != expected):
        raise Exception(f"Não é o tempo padrão ({answer}).")
    return answer

@keyword("Eu seleciono o tempo de operação '${valor}' e espero '${resultado}'")
def select_operating_time(valor, resultado):
    ts = "+"+ str(valor)
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Recebido '{answer}' e esperado '{resultado}'") 
    return ({answer})

@keyword("Eu consulto o tempo de operação e espero '${resultado}'")
def request_operating_time(resultado):
    ts = "+"
    answer = send_command_to_antiskimming(ts)[1:]
    if answer != resultado:
       raise Exception(f"Recebido '{answer}' e esperado '{resultado}'") 
    return ({answer})

@keyword("Aplica os valores de fábrica para os parâmetros")
def Applies_factory_values_parameters():
    answer = send_command_to_antiskimming("P")[1:]
    if answer != answer_success:
        raise Exception(f"Falha na consulta ({answer}).")
    return answer