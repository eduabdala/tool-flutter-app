# serial_test.py
import serial

# Abre a porta serial
ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=1)

# Envia um comando
ser.write(b'-e lix\r\n')

# Espera e lê a resposta (se houver)
response = ser.readline()
print("Resposta da placa:", response.decode('utf-8', errors='ignore'))

ser.close()
