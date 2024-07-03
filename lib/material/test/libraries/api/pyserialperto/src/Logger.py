import logging
import queue
from logging.handlers import QueueHandler, QueueListener
import datetime as dt
import os

class Logger():
    '''
    Implementation of logging that sets a layer above the python logging module, 
    to facilitate log manipulation and have the possibility to create multiple logs

    usage:
        from Logger import Logger
        import datetime

        ### You can start the log on object creation:
        #All parameters here are optional
        log1 = Logger("log1", "./log1.log", start_logging_on_creation=True, start_message="Eu sou o log 1"))

        ### You can initialize the Logger object, then start logging later
        #All parameters here are optional
        log1 = Logger("log1", "./log_1_{}.log".format(datetime.datetime.now().strftime("%Y%m%d%H%M%S")))
        log2 = Logger("log2", "./log_2_{}.log".format(datetime.datetime.now().strftime("%Y%m%d%H%M%S")))
        log1.start_log('Início do log1: {}'.format(datetime.datetime.now().strftime("%d-%b-%Y %H:%M:%S")))
        log2.start_log('Início do log2: {}'.format(datetime.datetime.now().strftime("%d-%b-%Y %H:%M:%S")))

        log1.logger.info("Eu sou o log 1")
        log2.logger.info("Eu sou o log 2")

        log1.logger.debug("Eu sou um debug do log 1")
        log2.logger.debug("Eu sou um debug do log 2")

        log1.logger.error("Eu sou um erro do log 1")
        log2.logger.error("Eu sou um erro do log 2")

        #All parameters here are optional
        log1.shutdown_log('Fim do log1: {}'.format(datetime.datetime.now().strftime("%d-%b-%Y %H:%M:%S")))
        log2.shutdown_log('Fim do log2: {}'.format(datetime.datetime.now().strftime("%d-%b-%Y %H:%M:%S")))

        #You can delete the log objects after shutdown if you want
        del log1
        del log2

    raise:
        Logger.Error: when invalid operations executed or invalid config received.

    '''
    __version__ = "1.2.0"
    __author__ = "William Schmidt Soares"
    __contact__ = "william.soares@perto.com.br"
    __copyright__ = "Copyright 2022, Perto S.A"

    INFO_LEVEL = logging.INFO
    DEBUG_LEVEL = logging.DEBUG
    WARNING_LEVEL = logging.WARNING
    ERROR_LEVEL = logging.ERROR
    CRITICAL_LEVEL = logging.CRITICAL
    NOTSET_LEVEL = logging.NOTSET

    def __init__(self, name="log", log_file="./log.log", format='%(asctime)s %(levelname)s : %(message)s', dateformat='%Y-%m-%d %H:%M:%S.%f', level=DEBUG_LEVEL, start_logging_on_creation=False, start_message=None):
        self.__name = name
        self.__log_file = log_file
        self.__level = level
        self.__formatter = Logger.MyFormatter(fmt=format,datefmt=dateformat)
        self.__log_queue = queue.Queue(-1)
        self.__queue_handler = QueueHandler(self.__log_queue)
        if start_logging_on_creation is True:
            self.start_log(start_message)

    def start_log(self, message = None):
        if not self.__check_if_logging():
            self.__create_dir(self.__log_file)
            self.logger = logging.getLogger(self.__name)
            self.logger.setLevel(self.__level)
            self.logger.addHandler(self.__queue_handler)
            self.__file_handler = logging.FileHandler(self.__log_file)
            self.__file_handler.setFormatter(self.__formatter)
            self.listener = QueueListener(self.__log_queue, self.__file_handler)
            self.listener.start()
            if message is not None:
                self.logger.info(message)

    def shutdown_log(self, message = None):
        if self.__check_if_logging():
            if message is not None:
                self.logger.info(message)
            self.listener.stop()
            self.logger.handlers.clear()
            self.logger = logging.shutdown()
            del self.logger

    def set_log_name(self, name):
        if self.__check_if_logging():
            raise self.Error("Can't set the log name while logging!")
        else:
            self.__name = name

    def set_log_file(self, log_file):
        if self.__check_if_logging():
            raise self.Error("Can't set a log file while logging!")
        else:
            self.__log_file = log_file

    def set_log_level(self, level):
        if self.__check_if_logging():
            raise self.Error("Can't set the log level while logging!")
        else:
            self.__level = level

    def set_log_formatter(self, format, dateformat=None):
        if self.__check_if_logging():
            raise self.Error("Can't set a formatter while logging!")
        else:
            self.__formatter = Logger.MyFormatter(fmt=format,datefmt=dateformat)

    def get_log_name(self):
        return self.__name

    def get_log_file(self):
        return self.__log_file

    def get_log_level(self):
        return self.__level

    def get_log_formatter(self):
        return self.__formatter

    def convert_bytes_to_ascii(self, bytes_to_convert):
        converted = []
        for byte_to_convert in bytes_to_convert:
            if (byte_to_convert > 32 and byte_to_convert < 127):
                converted.append(chr(byte_to_convert))
            else:
                converted.append(".")
        return ''.join(converted)

    def convert_bytes_to_hex_string(self, bytes_to_convert):
        return bytes_to_convert.hex().upper()

    def __check_if_logging(self):
        if not hasattr(self, f'logger'):
            return False
        else:
            return True

    def __create_dir(self, log_file):
        dir_name = os.path.dirname(log_file)
        os.makedirs(dir_name, exist_ok=True)

    class Error(Exception):
        pass

    class MyFormatter(logging.Formatter):
        converter=dt.datetime.fromtimestamp # type: ignore
        def formatTime(self, record, datefmt=None):
            ct = self.converter(record.created)
            if datefmt:
                s = ct.strftime(datefmt)
            else:
                t = ct.strftime("%Y-%m-%d %H:%M:%S")
                s = "%s,%03d" % (t, record.msecs)
            return s
