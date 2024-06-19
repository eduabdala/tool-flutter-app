from .PertoSerialHandler import PertoSerialHandler
from serial.serialutil import *
import serial

class SerialCommunication():

    def __init__(self, port, baudrate, bytesize=EIGHTBITS, parity=PARITY_NONE, stopbits=STOPBITS_ONE, timeout=None, xonxoof=False, rtscts=False, dsrdtr=False, write_timeout=0.01, inter_byte_timeout=None, exclusive=True, debug_ret=None, debug_serial=None, protocol=PertoSerialHandler.Protocol.PERTO_DIRETO):
        self.protocol = protocol
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=bytesize,
            parity=parity,
            stopbits=stopbits,
            timeout=timeout,
            xonxoff=xonxoof,
            rtscts=rtscts,
            dsrdtr=dsrdtr,
            write_timeout=write_timeout,
            inter_byte_timeout=inter_byte_timeout,
            exclusive=exclusive
        )
        self.USB = PertoSerialHandler(ser,debug_serial,protocol=self.protocol)

    def SendCommand(self, command, timeout=None, send_delay=0):
            resp = None
            self.USB.port.close()
            try:
                self.USB.port.open()
            except SerialException as error:
                resp = str(error)
                print("CAIU a COM ")
            else:
                try:
                    resp = self.USB.Handler_SendAndReceive(command, timeout, protocol=self.protocol)
                except (TypeError, SerialException) as error:
                    self.USB.pertoDireto_flush()
                    resp = str(error)
            finally:
                self.USB.port.close()
                return resp
