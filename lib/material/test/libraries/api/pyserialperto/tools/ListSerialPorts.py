#!/usr/bin/env python
import sys
import glob
import serial
import serial.tools.list_ports

class ListSerial(object):
    def __init__(self):
        pass


    def serial_ports(self):
        """ Lists serial port names

            :raises EnvironmentError:
                On unsupported or unknown platforms
            :returns:
                A list of the serial ports available on the system
        """

        if sys.platform.startswith('win'):
            #ports = ['COM%s' % (i + 1) for i in range(256)]
            ports = serial.tools.list_ports.comports()
        elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
            # this excludes your current terminal "/dev/tty"
            ports = glob.glob('/dev/tty[A-Za-z]*')
        elif sys.platform.startswith('darwin'):
            ports = glob.glob('/dev/tty.*')
        else:
            raise EnvironmentError('Unsupported platform')

        result = []
        for port in ports:
            try:
                #s = serial.Serial(port)
                #s.close()
                formatted_port = str(port)
                result.append(formatted_port.split()[0])
            except (OSError, serial.SerialException):
                pass
        #return result
        result.sort()
        return sorted(result, key=len)
    def getUSBVID_PID(self):
        for port in serial.tools.list_ports.comports():
            print(port.hwid)
        

if __name__ == '__main__':    
    ser = ListSerial()
    print(ser.serial_ports())
    ser.getUSBVID_PID()
