'''Biblioteca de comunicação da perto.

usage:
    #Import all deps
    from serial import Serial as ThirdySerial
    from pyserialperto import *

    #Interface Config
    AntiSkimming = (PertoApi()
        .setHandler.prefix(b'\\x02')
        .setHandler.suffix(b'\\x03')
        .setHandler.hash(ErrorDetect.bcc8)
        .setHandler.strip(Strip.regex(rb'\\x02(.*)\\x03'))
        .setHandler(PertoHandler.simple)
        .setInterface.timeout('ack', 0.25)
        .setInterface.timeout('cmd', 0.2)
        .setInterface.timeout('between', 0.1)
        .setInterface.serial('port', 'COM3')
        .setInterface.serial('baudrate', 19200)
        .setInterface.serial_class(ThirdySerial)
        .setInterface.logger(Logger("log", "./log.log"))
        .setInterface(PertoInterface.serial)
        .setPipeline(PertoCommand.pipeline)
    )

    #Output: True
    AntiSkimming.cmd('V0').expect(b'VF15GXS03').non_fail().send()

    #Optional sets:
        .setHandler.prefix(b'\\x02')
        .setHandler.suffix(b'\\x03')
        .setHandler.hash(ErrorDetect.bcc8)
        .setHandler.strip(Strip.regex(rb'\\x02(.*)\\x03'))
        .setInterface.tries('number_of_tries', 3)           #Needs change on interface to PertoInterface.serial_with_tries
        .setInterface.tries('time_between_tries', 0.1)      #Needs change on interface to PertoInterface.serial_with_tries
        .setInterface.timeout('ack', 0.25)
        .setInterface.timeout('response', 0.001)
        .setInterface.timeout('ack_byte', b'\\x06')
        .setInterface.timeout('nack_byte', b'\\x15')
        .setInterface.serial('rtscts', True)
        .setInterface.serial('dsrdtr', False)
        .setInterface.logger(Logger("log", "./log.log"))

raise:
    Strip.Error
    Logger.Error
    PertoApi.Error
    PertoHandler.Error
    PertoCommand.Fail
    PertoCommand.Error
    PertoInterface.Error
'''
# Notice
__version__ = "2.2.0" #pragma: no cover
__copyright__ = "Copyright 2022, Perto S.A" #pragma: no cover

# Import fixture
import sys, os #pragma: no cover
sys.path.append(os.path.abspath(os.path.dirname(__file__)+'/src')) #pragma: no cover

# GENERIC COMPONENTS
from .src.Strip import Strip #pragma: no cover
from .src.Logger import Logger #pragma: no cover
from .tools.DateHandler import DateHandler #pragma: no cover
# PERTO COMPONENTS
from .src.PertoApi import PertoApi #pragma: no cover
from .src.ErrorDetect import ErrorDetect #pragma: no cover
from .src.PertoHandler import PertoHandler #pragma: no cover
from .src.PertoCommand import PertoCommand #pragma: no cover
from .src.PertoInterface import PertoInterface #pragma: no cover
from .legacy.PertoSerialHandler import PertoSerialHandler #pragma: no cover
from .legacy.SerialCommunication import SerialCommunication #pragma: no cover

# Clean up
del sys, os # pragma:no cover
if 'src' in locals(): #pragma: no cover
    del src # pragma:no cover
if 'tools' in locals(): #pragma: no cover
    del tools # pragma:no cover
if 'legacy' in locals(): #pragma: no cover
    del legacy # pragma:no cover
