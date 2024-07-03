from Logger import Logger
import os
import pytest

#def test_folder_dont_exist():
#    with pytest.raises(FileNotFoundError) as excinfo:
#        log = Logger("log", "C:/logs_serial/logs_serial.log")
#    assert "[Errno 2] No such file or directory: 'C:\\\\logs_serial\\\\logs_serial.log'" in str(excinfo.value)


def test_bytes_to_hex_string_conversion():
    log = Logger()
    message = b'\x01\x50\x60\xFF'
    assert log.convert_bytes_to_hex_string(message) == "015060FF"

def test_bytes_to_ascii_conversion():
    log = Logger()
    message = b'\x01\x1F\x20\x21\x7F\x7E\xFF'
    assert log.convert_bytes_to_ascii(message) == "...!.~."

def test_set_log_config():
    log_name = "log"
    log_file = "./testLog.log"
    log_level = Logger.INFO_LEVEL
    format = '%(asctime)s.%(msecs)03d %(levelname)s : %(message)s'
    dateformat = '%Y-%m-%d %H:%M:%S'
    log = Logger()
    log.set_log_name(log_name)
    log.set_log_file(log_file)
    log.set_log_level(log_level)
    log.set_log_formatter(format, dateformat)
    assert log.get_log_name() == log_name
    assert log.get_log_file() == log_file
    assert log.get_log_level() == log_level
    assert log.get_log_formatter()._fmt == format
    assert log.get_log_formatter().datefmt == dateformat

class Test_set_log_name_while_log_running_error():
    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))
        self.log = Logger("log", "./testLog.log")
        self.log.start_log()

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        self.log.shutdown_log()
        os.remove("./testLog.log")

    def test_logging_set_log_name_while_log_running_error(self):
        with pytest.raises(Logger.Error) as excinfo:
            self.log.set_log_name("log")
        assert "Can't set the log name while logging!" in str(excinfo.value)

class Test_set_log_file_while_log_running_error():
    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))
        self.log = Logger("log", "./testLog.log")
        self.log.start_log()

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        self.log.shutdown_log()
        os.remove("./testLog.log")

    def test_logging_set_log_file_while_log_running_error(self):
        with pytest.raises(Logger.Error) as excinfo:
            self.log.set_log_file("./testLog.log")
        assert "Can't set a log file while logging!" in str(excinfo.value)

class Test_set_log_level_while_log_running_error():
    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))
        self.log = Logger("log", "./testLog.log")
        self.log.start_log()

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        self.log.shutdown_log()
        os.remove("./testLog.log")

    def test_logging_set_log_level_while_log_running_error(self):
        with pytest.raises(Logger.Error) as excinfo:
            self.log.set_log_level(Logger.DEBUG_LEVEL)
        assert "Can't set the log level while logging!" in str(excinfo.value)

class Test_set_log_formatter_while_log_running_error():
    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))
        self.log = Logger("log", "./testLog.log")
        self.log.start_log()

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        self.log.shutdown_log()
        os.remove("./testLog.log")

    def test_logging_set_log_formatter_while_log_running_error(self):
        with pytest.raises(Logger.Error) as excinfo:
            self.log.set_log_formatter('%(asctime)s.%(msecs)03d %(levelname)s : %(message)s', '%Y-%m-%d %H:%M:%S')
        assert "Can't set a formatter while logging!" in str(excinfo.value)

class Test_logging_message_on_inicialization_and_closure():
    def setup_method(self, method):
        log = Logger("log", "./testLog.log")
        log.start_log("Hello People!")
        log.shutdown_log("Goodbye People!")
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        os.remove("./testLog.log")

    def test_logging_logging_message_on_inicialization_and_closure(self):
        with open("./testLog.log") as f:
            lines = f.readlines()
        f.close()
        assert lines[0][-14:] == "Hello People!\n"
        assert lines[1][-16:] == "Goodbye People!\n"

class Test_logging_message_with_object_inicialization():
    def setup_method(self, method):
        log = Logger("log", "./testLog.log", start_logging_on_creation=True, start_message="Hello People!")
        log.shutdown_log("Goodbye People!")
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        os.remove("./testLog.log")

    def test_logging_logging_message_with_object_inicialization(self):
        with open("./testLog.log") as f:
            lines = f.readlines()
        f.close()
        assert lines[0][-14:] == "Hello People!\n"
        assert lines[1][-16:] == "Goodbye People!\n"

class Test_logging_message_with_no_dateformatter():
    def setup_method(self, method):
        log = Logger("log", "./testLog.log", dateformat=None)
        log.start_log("Hello People!")
        log.shutdown_log("Goodbye People!")
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        os.remove("./testLog.log")

    def test_logging_logging_message_with_no_dateformatter(self):
        with open("./testLog.log") as f:
            lines = f.readlines()
        f.close()
        print(lines[0])
        assert lines[0][-14:] == "Hello People!\n"
        assert lines[0][4] == "-"
        assert lines[0][7] == "-"
        assert lines[0][13] == ":"
        assert lines[0][16] == ":"
        assert lines[0][19] == ","
        assert lines[0][24:28] == "INFO"
        assert lines[1][-16:] == "Goodbye People!\n"
        assert lines[1][4] == "-"
        assert lines[1][7] == "-"
        assert lines[1][13] == ":"
        assert lines[1][16] == ":"
        assert lines[1][19] == ","
        assert lines[1][24:28] == "INFO"

class Test_logging_test_file():
    @classmethod
    def setup_class(klass):
        print("STARTING class: {} execution".format(klass.__name__))
        log = Logger("log", "./testLog.log")
        log.start_log()
        log.logger.info("I have been tested successfully")
        log.shutdown_log()

    @classmethod
    def teardown_class(klass):
        print("ENDING class: {} execution".format(klass.__name__))
        os.remove("./testLog.log")

    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))

    def test_logging_logging_to_test_file(self):
        with open("./testLog.log") as f:
            line = f.readline()
        f.close()
        assert line[-32:] == "I have been tested successfully\n"

class Test_logging_test_two_files():
    @classmethod
    def setup_class(klass):
        print("STARTING class: {} execution".format(klass.__name__))
        log1 = Logger("log1", "./testLog1.log")
        log2 = Logger("log2", "./testLog2.log")
        log1.start_log()
        log2.start_log()
        log1.logger.info("Log1 have been tested successfully")
        log1.shutdown_log()
        log2.logger.info("Log2 have been tested successfully")
        log2.shutdown_log()

    @classmethod
    def teardown_class(klass):
        print("ENDING class: {} execution".format(klass.__name__))
        os.remove("./testLog1.log")
        os.remove("./testLog2.log")

    def setup_method(self, method):
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))

    def test_logging_logging_to_two_files(self):
        with open("./testLog1.log") as f:
            line = f.readline()
        f.close()
        assert line[-35:] == "Log1 have been tested successfully\n"
        with open("./testLog2.log") as f:
            line = f.readline()
        f.close()
        assert line[-35:] == "Log2 have been tested successfully\n"

class Test_logging_creating_directory():
    def setup_method(self, method):
        log = Logger("log", "./log/testLog.log", start_logging_on_creation=True)
        log.shutdown_log()
        print("STARTING execution of testcase: {}".format(method.__name__))

    def teardown_method(self, method):
        print("ENDING execution of testcase: {}".format(method.__name__))
        os.remove("./log/testLog.log")
        os.rmdir("./log")

    def test_logging_logging_creating_directory(self):
        result = os.path.isdir("./log")
        assert True == result

