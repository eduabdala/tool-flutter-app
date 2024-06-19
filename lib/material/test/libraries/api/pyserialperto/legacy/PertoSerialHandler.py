from ..src.ErrorDetect import ErrorDetect
from ..src.Logger import Logger
import serial
import time
import sys
import datetime
import glob
import codecs
import logging
import os


#TODO:Tratar  bytes que ficaram na fila da serial
class PertoSerialHandler():
    """ 
        Class with basic funcions to handling of serial 

    """
    ACK = '06'   #Acknowledgment
    NACK ='15'   #No acknowledgment
    STX = '02'   #Header
    ETX = '03'   #Trailer
    DESTINATION = '48'
    ORIGIN = '29'
    INI = "01"
    SOH = '04'
    SOH_CASH_BCC = '01'             #Response package
    EOT_CASH_BCC = '04'             #Sending package
    HOST_CASH_BCC = '30'            #Host Address
    DEVICE_CASH_BCC = '30'          #Device Address
    SOH_CASH_CRC = '01'             #Response package
    EOT_CASH_CRC = '04'             #Sending package
    HOST_CASH_CRC = '30'            #Host Address
    DEVICE_CASH_CRC = '51'          #Device Address

    class Protocol():
        """
        Protocol options
        """
        NO_PROTOCOL = 0
        PERTO_DIRETO = 1
        PERTO_DIRETO_485 = 2
        CASH_BCC = 3
        CASH_CRC = 4

    """
                Constructor of class PertoSerialHandler 
        params:
            port: serial comunication port
            verbose: enables debugger option
            protocol: type of protocol to be used
    """
    def __init__(self, port, verbose=None, protocol=Protocol.PERTO_DIRETO, logger=None):
        self.verbose = verbose
        self.port = port
        self.protocol = protocol
        self.log_serial = logger

    """
            print data with current time
    """
    def dbg_print(self, data):
        if self.verbose is None:
            return
        tempo = datetime.datetime.fromtimestamp(
            time.time()).strftime('%H:%M:%S.%f')
        print('[{}] Serial_handler: {}'.format(tempo, data))
        if (self.log_serial != None):
            self.log_serial.logger.info('[{}] Serial_handler: {}'.format(tempo, data))

    
    def _rawSend(self, data):
        """
            Send data without protocol
        param:
            data: data to bo sent
        """
        if not self.port.isOpen():
            self.dbg_print('serial {} is not open'.format(self.port.port))
            return -1

        if len(data) % 2 != 0:
            self.dbg_print('buffer size error, must be pair')
            return -2

        self.dbg_print('send hex: {}'.format(data))

        data = bytes.fromhex(data)
        sent = self.port.write(data)
        return sent


    def _rawReceive(self, timeout=None, trailer=None):
        """
            Receive data without protocol treatment

        params:
            timeout: timeout that the serial port will be waiting for a byte
            trailer: last byte to be received before sending an ACK.
        """
        
        out = ''
        st_init = time.time()
        while self.port.inWaiting() <= 0:
            
            if (st_init + float(timeout)) <= time.time():
                self.dbg_print('timeout error')
                return -1
        last_byte = time.time()
        #TODO: deixar o delay between bytes configuravel
        while time.time() < (last_byte + 0.050):
            if self.port.inWaiting() > 0:
                last_byte = time.time()
                char = self.port.read(1)
                char = char.hex()
                out += char
                if trailer is not None:
                    if char == trailer:
                        self._rawSend(self.ACK)
                        return out

        self.dbg_print('receive hex: {}'.format(out.upper()))                
        #self.dbg_print('rcv: {}{}{}'.format(out[0].encode("utf-8").hex(),out[1:-2],out[-2:].encode("utf-8").hex()))
        return out

    def _bccCalc(self, data):
        """
            Calculate block check character
        param:
            data: data that the bcc will be calculated
        """
        bcc = 0
        for i in range(0, len(data), 2):
            char = data[i:(i+2)]
            bcc ^= int(char, 16)
        return bcc

    def _pertoDireto_send(self, data):
        """
            Send data with protocol protocol treatment 
        param:
            data: data to be sent
        """
        self.dbg_print('send ascii: {}'.format(data))
        buffer = '02{}03'.format(data.encode("utf-8").hex())
        bcc = "{:02x}".format(self._bccCalc(buffer))
        buffer += bcc
        return self._rawSend(buffer)

    def _pertoDireto485_send(self, data):
        """
            Send data with protocol protocol treatment 
        param:
            data: data to be sent
        """
        self.dbg_print('send ascii: {}'.format(data))
        buffer = '04482902{}03'.format(data.encode("utf-8").hex())
        bcc = "{:02x}".format(self._bccCalc(buffer))
        buffer += bcc
        return self._rawSend(buffer)

    def _cash_BCC_send(self, data):
        """
            Send data with protocol protocol treatment 
        param:
            data: data to be sent
        """
        if (type(data) == str):
            self.dbg_print('send ascii: {}'.format(data))
            data = data.encode("utf-8").hex()
        else:
            data = data.hex()
        self.dbg_print('send ascii: {}'.format(data))
        buffer = '{EOT}{DEVICE}{HOST}{STX}{DATA}{ETX}'.format(EOT=self.EOT_CASH_BCC,DEVICE=self.DEVICE_CASH_BCC,HOST=self.HOST_CASH_BCC,STX=self.STX,DATA=data,ETX=self.ETX)
        bcc = "{:02x}".format(self._bccCalc(buffer))
        buffer += bcc
        return self._rawSend(buffer)

    def _cash_CRC_send(self, data):
        """
            Send data with protocol protocol treatment 
        param:
            data: data to be sent
        """
        if (type(data) == str):
            self.dbg_print('send ascii: {}'.format(data))
            data = data.encode("utf-8").hex()
        else:
            data = data.hex()
        buffer = '{EOT}{DEVICE}{HOST}{STX}{DATA}{ETX}'.format(EOT=self.EOT_CASH_CRC,DEVICE=self.DEVICE_CASH_CRC,HOST=self.HOST_CASH_CRC,STX=self.STX,DATA=data,ETX=self.ETX)
        buffer_crc = bytes.fromhex(buffer)
        crc = ErrorDetect.crc16_fitec(buffer_crc).hex()
        buffer += crc
        return self._rawSend(buffer.upper())

    def _pertoDireto_receive(self, timeout=None):
        """
            Receive data with protocol treatment
        param: 
            timeout: timeout that the serial port will be waiting for a byte
        """
        answer = str(self._rawReceive(timeout))
        return self._stripProtocol(answer)

    def _pertoDireto485_receive(self, timeout=None):
        """
            Receive data with protocol treatment
        param: 
            timeout: timeout that the serial port will be waiting for a byte
        """
        answer = str(self._rawReceive(timeout))
        return self._stripProtocol485(answer)

    def _cash_BCC_receive(self, timeout=None):
        """
            Receive data with protocol treatment
        param: 
            timeout: timeout that the serial port will be waiting for a byte
        """
        answer = str(self._rawReceive(timeout))
        return self._stripProtocol_cash_BCC(answer)

    def _cash_CRC_receive(self, timeout=None):
        """
            Receive data with protocol treatment
        param: 
            timeout: timeout that the serial port will be waiting for a byte
        """
        answer = str(self._rawReceive(timeout))
        return self._stripProtocol_cash_CRC(answer)
    
    def _waitACK(self, timeout=0.250):
        """
            Wait to receive acknowledgment byte
        param:
            timeout: timeout to receive ACK byte from device
        """
        ret_ack = False
        st_init = time.time()
        while self.port.inWaiting() <= 0:
            if (st_init + float(timeout)) <= time.time():
                self.dbg_print('timeout error')
                return ret_ack
        ack = self.port.read(1).decode("utf-8")
        if(ack == '\x06'):
            self.dbg_print("ACK RECEIVED: {}".format(bytes(ack,'utf-8').hex()))
            ret_ack = True
        elif(ack == '\x15'):
            self.dbg_print("NACK RECEIVED: {}".format(bytes(ack,'utf-8').hex()))
        
        return ret_ack

    def _stripProtocol(self, data_in):
        """
            "Treatment of protocol"
        param:
            data_in:  data to be verified
        """
        data_in = bytes.fromhex(data_in)
        data_in = data_in.decode("utf-8")
        buffer = data_in[0:-1].encode("utf-8").hex()
        if len(data_in) < 4:
            raise TypeError('Answer size error')
        elif (data_in[0].encode("utf-8").hex() != self.STX):
            print(data_in[0].encode("utf-8").hex())
            raise TypeError('STX error')
        elif (data_in[-2].encode("utf-8").hex() != self.ETX):
            raise TypeError('ETX error')
        elif (self._bccCalc(buffer) != ord(data_in[-1])):
            raise TypeError('BCC error')
        self.dbg_print('receive ascii: {}'.format(data_in[1:-2]))
        self._rawSend(self.ACK)
        return data_in[1:-2]

    def _stripProtocol485(self, data_in):
        """
            "Treatment of protocol"
        param:
            data_in:  data to be verified
        """
        data_in = bytes.fromhex(data_in)
        data_in = data_in.decode("utf-8")
        buffer = data_in[0:-1].encode("utf-8").hex()
        if len(data_in) < 8:
            raise TypeError('Answer size error')
        elif (data_in[0].encode("utf-8").hex() != self.INI):
            raise TypeError('INI error')
        elif (data_in[1].encode("utf-8").hex() != self.ORIGIN):
            raise TypeError('ORIGIN error')
        elif (data_in[2].encode("utf-8").hex() != self.DESTINATION):
            raise TypeError('DESTINATION error')
        elif (data_in[3].encode("utf-8").hex() != self.STX):
            print(data_in[0].encode("utf-8").hex())
            raise TypeError('STX error')
        elif (data_in[-2].encode("utf-8").hex() != self.ETX):
            raise TypeError('ETX error')
        elif (self._bccCalc(buffer) != ord(data_in[-1])):
            raise TypeError('BCC error')
        self.dbg_print('receive ascii: {}'.format(data_in[4:-2]))
        self._rawSend(self.ACK)
        return data_in[4:-2]

    def _stripProtocol_cash_BCC(self, data_in):
        """
            "Treatment of protocol"
        param:
            data_in:  data to be verified
        """
        data_in = bytes.fromhex(data_in)
        data_in = data_in.decode("utf-8")
        buffer = data_in[0:-1].encode("utf-8").hex()
        if len(data_in) < 8:
            raise TypeError('Answer size error')
        elif (data_in[0].encode("utf-8").hex() != self.SOH_CASH_BCC):
            raise TypeError('SOH error')
        elif (data_in[1].encode("utf-8").hex() != self.DEVICE_CASH_BCC):
            raise TypeError('DEVICE error')
        elif (data_in[2].encode("utf-8").hex() != self.HOST_CASH_BCC):
            raise TypeError('HOST error')
        elif (data_in[3].encode("utf-8").hex() != self.STX):
            print(data_in[0].encode("utf-8").hex())
            raise TypeError('STX error')
        elif (data_in[-2].encode("utf-8").hex() != self.ETX):
            raise TypeError('ETX error')
        elif (self._bccCalc(buffer) != ord(data_in[-1])):
            raise TypeError('BCC error')
        self.dbg_print('receive ascii: {}'.format(data_in[4:-2]))
        self._rawSend(self.ACK)
        return data_in[4:-2]

    def _stripProtocol_cash_CRC(self, data_in):
        """
            "Treatment of protocol"
        param:
            data_in:  data to be verified
        """

        buffer = bytes.fromhex(data_in[0:-4]).decode("utf-8")
        if len(buffer) < 8:
            raise TypeError('Answer size error')
        elif (buffer[0].encode("utf-8").hex() != self.SOH_CASH_CRC):
            raise TypeError('SOH error')
        elif (buffer[1].encode("utf-8").hex() != self.DEVICE_CASH_CRC):
            raise TypeError('DEVICE error')
        elif (buffer[2].encode("utf-8").hex() != self.HOST_CASH_CRC):
            raise TypeError('HOST error')
        elif (buffer[3].encode("utf-8").hex() != self.STX):
            raise TypeError('STX error')
        elif (buffer[-1].encode("utf-8").hex() != self.ETX):
            raise TypeError('ETX error')
        elif (ErrorDetect.crc16_fitec(buffer.encode("utf-8")).hex() != data_in[-4:]):
            raise TypeError('CRC error')
        self.dbg_print('receive ascii: {}'.format(buffer[4:-1]))
        self._rawSend(self.ACK)
        return buffer[4:-1]

    def pertoDireto_flush(self,timeout=3):
        """
            Flush of file like objects. In this case, wait until all data is written.
        """
        flushed = True
        st_init = time.time()
        while self.port.inWaiting()!=0:
            if (st_init + float(timeout)) <= time.time():
                flushed = False
                self.dbg_print('timeout error')
                break
            self._rawReceive(timeout)
        return flushed

    def HandlerSend(self, data):
        """
            Send data to serial according to selected protocol
        param:
            data: data to be sent
        """
        if self.protocol == PertoSerialHandler.Protocol.PERTO_DIRETO:
            self._pertoDireto_send(data)

        elif self.protocol == PertoSerialHandler.Protocol.NO_PROTOCOL:
            self._rawSend(data)

    def HandlerReceive(self, timeout=None):
        """
            Receive data from the serial bus according to the selected protocol
        param:
            timeout: timeout that the serial port will be waiting for a byte

        """
        resp = None
        if self.protocol == PertoSerialHandler.Protocol.PERTO_DIRETO:
            resp = self._pertoDireto_receive(timeout)
        elif self.protocol == PertoSerialHandler.Protocol.NO_PROTOCOL:
            resp=self._rawReceive(timeout)
        return resp



    def Handler_SendAndReceive(self,command, cmd_timeout=1, ack_timeout=0.350, send_delay=0, protocol=Protocol.PERTO_DIRETO):
        """
            Send command and receive command response

        params:
            command: Command to be sent
            cmd_timeout: timeout to receive response
            ack_timeout: timout to receive ack response
            send_delay: time between sending the command and requesting the response
    
        """
        if (protocol == PertoSerialHandler.Protocol.PERTO_DIRETO):
            self._pertoDireto_send(command)
            time.sleep(send_delay)
            if self._waitACK(ack_timeout) is False:
                raise TypeError("ACK timeout")
            return self._pertoDireto_receive(cmd_timeout)
        elif (protocol == PertoSerialHandler.Protocol.PERTO_DIRETO_485):
            self._pertoDireto485_send(command)
            time.sleep(send_delay)
            if self._waitACK(ack_timeout) is False:
                raise TypeError("ACK timeout")
            return self._pertoDireto485_receive(cmd_timeout)
        elif (protocol == PertoSerialHandler.Protocol.CASH_BCC):
            self._cash_BCC_send(command)
            time.sleep(send_delay)
            if self._waitACK(ack_timeout) is False:
                raise TypeError("ACK timeout")
            return self._cash_BCC_receive(cmd_timeout)
        elif (protocol == PertoSerialHandler.Protocol.CASH_CRC):
            self._cash_CRC_send(command)
            time.sleep(send_delay)
            if self._waitACK(ack_timeout) is False:
                raise TypeError("ACK timeout")
            return self._cash_CRC_receive(cmd_timeout)
        else:
            self._rawSend(command)
            time.sleep(send_delay)
            return self._rawReceive(cmd_timeout)
