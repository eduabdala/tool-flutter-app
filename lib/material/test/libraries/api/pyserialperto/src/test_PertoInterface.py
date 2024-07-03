from PertoInterface import PertoInterface
import pytest, tempfile

tmp = tempfile.NamedTemporaryFile(delete=False)
tmp_log = tempfile.NamedTemporaryFile(delete=False)
tmp_tries = tempfile.NamedTemporaryFile(delete=False)

class FakeSerial():
    def __init__(self, port):
        self.res = port
        pass

    def inWaiting(self):
        return len(self.res)

    #$def isOpen(self):
    #    return True

    def open(self):
        pass

    def read(self, size):
        return self.res.pop().encode()

    def write(self, buffer):
        self.res = (buffer + '|' + self.res).split()
        return buffer

    def close(self):
        pass

class FakeSerialReturn(FakeSerial):
    def read(self, size):
        res = self.res
        self.res = b''
        return res

    def write(self, buffer):
        self.res = buffer
        return self.res

class FakeSerialLazy(FakeSerial):
    def inWaiting(self):
        return 0

class FakeSerialError(FakeSerial):
    def __init__(self, port, tries, tries_file):
        self.res = port
        self.tries = tries
        self.in_try = None
        self.tries_file = tries_file
        pass

    def write(self, buffer):
        self.in_try = int(self.add_one_try())
        if (self.in_try < self.tries):
            raise Exception("Try error")
        else:
            self.reset_tries()
            self.res = (buffer + '|' + self.res).split()
            return buffer

    def load_try(self):
        with open(self.tries_file, 'r') as file:
            current_try = file.read()
        if (current_try == ""):
            current_try = self.reset_tries() 
        return current_try

    def reset_tries(self):
        info = "0"
        with open(self.tries_file, 'w') as file:
            file.write(info)
        return info

    def add_one_try(self):
        current_try = self.load_try()
        current_try_plus_one = int(current_try)+1
        current_try_plus_one = str(current_try_plus_one)
        with open(self.tries_file, 'w') as file:
            file.write(current_try_plus_one)
        return current_try_plus_one

class FakeLogger():
    def __init__(self, log_file):
        self.logger = FakeLogHandler(log_file)
        pass

    def convert_bytes_to_ascii(self, bytes_to_convert):
        return bytes_to_convert

    def convert_bytes_to_hex_string(self, bytes_to_convert):
        return bytes_to_convert

class FakeLogHandler():
    def __init__(self, log_file):
        self.log_file = log_file
        pass

    def info(self, message):
        with open(self.log_file, 'ba+') as file:
            file.write(message)
        return message

    def debug(self, message):
        with open(self.log_file, 'ba+') as file:
            file.write(message)
        return message

class FakeSerialHasher(FakeSerial):
    def __init__(self, port):
        FakeSerialHasher.hashed = False
        pass

    def inWaiting(self):
        if FakeSerialHasher.hashed == False:
            return len(self.res)-1
        else:
            return len(self.res)

    def write(self, buffer):
        self.res = buffer

    def read(self, size):
        return self.res.pop(0).encode()

    @staticmethod
    def hasher(buffer):
        FakeSerialHasher.hashed = True
        return buffer  

config = {
    'serial_cfg': {
        'file': tmp.name,
        'file_pointer': tmp,
        'serial_class': FakeSerial,
        'serial': {
            'port': 'COM'
        },
        'timeout': {
            'between': 0.0001,
            'cmd': 0.0001,
            'response': 0.0001
        }
    },
    'handler_cfg': {
    }
}

config2 = {
    'serial_cfg':{
        'file_pointer': tmp_log,
        'logger': FakeLogger(tmp_log.name)
    },
    'handler_cfg': {
    }
}

config3 = {
    'serial_cfg':{
        'serial_class': FakeSerialError,
        'serial': {
            'port': 'COM',
            'tries': 2,
            'tries_file': tmp_tries.name
        },
        'timeout': {
            'between': 0.0001,
            'cmd': 0.0001,
        },
        'tries': {
            'number_of_tries': 3,
            'time_between_tries': 0.0001,
        }
    },
    'handler_cfg': {
    }
}

config4 = {
    'serial_cfg': {
        'serial_class': FakeSerialReturn,
        'serial': {
            'port': 'COM'
        },
        'timeout': {
            'between': 0.0001,
            'cmd': 0.0001,
            'ack': 0.0001,
            'ack_byte': b'\x20',
            'return_ack': True
        }
    },
    'handler_cfg': {
    }
}

config5 = {
    'serial_cfg': {
        'serial_class': FakeSerialReturn,
        'serial': {
            'port': 'COM'
        },
        'timeout': {
            'between': 0.0001,
            'cmd': 0.0001,
            'ack': 0.0001,
            'nack_byte': b'\x30',
            'return_ack': False
        }
    },
    'handler_cfg': {
    }
}

def test_interface_serial():
    result = PertoInterface.serial('foo', config)
    assert b'foo|COM' == result

def test_interface_serial_write():
    result = PertoInterface.serial_write('foo', config)
    assert 'foo' == result

def test_interface_file():
    result = PertoInterface.file_write(b'foo', config['serial_cfg'])
    assert b'foo' == config['serial_cfg']['file_pointer'].read()
    assert b'foo' == result

def test_interface_logging():
    result = PertoInterface.log_into_file(b'foo', config2['serial_cfg'])
    assert b'foofoo' == config2['serial_cfg']['file_pointer'].read()
    assert b'foo' == result

def test_interface_logging_mode_1():
    result = PertoInterface.log_into_file(b'foo', config2['serial_cfg'], 1)
    assert b'foo' == config2['serial_cfg']['file_pointer'].read()
    assert b'foo' == result

def test_interface_tries():
    result = PertoInterface.serial_with_tries('foo', config3)
    assert b'foo|COM' == result

def test_interface_tries_error():
    with pytest.raises(Exception) as excinfo:
        PertoInterface.serial_with_tries('foo', {**config3,
            'serial_cfg': {
                'serial_class': FakeSerialError,
                'serial': {
                    'port': 'COM',
                    'tries': 4,
                    'tries_file': tmp_tries.name
                },
                'timeout': {
                    'between': 0.0001,
                    'cmd': 0.0001,
                },
                'tries': {
                    'number_of_tries': 3,
                    'time_between_tries': 0.0001,
                }
            }
        })
    assert "Try error" in str(excinfo.value)

def test_interface_ack():
    result = PertoInterface.serial(b'\x20', config4)
    assert b'\x20' == result

def test_interface_ack_error():
    with pytest.raises(PertoInterface.Error) as excinfo:
        PertoInterface.serial(b'\x21', config4)
    assert "Ack 21 received is different from ack 20 and nack 15 configured" in str(excinfo.value)

def test_interface_nack():
    result = PertoInterface.serial(b'\x30', config5)
    assert b'\x30' == result

def test_interface_nack_error():
    with pytest.raises(PertoInterface.Error) as excinfo:
        PertoInterface.serial(b'\x21', config5)
    assert "Ack 21 received is different from ack 06 and nack 30 configured" in str(excinfo.value)

def test_interface_serial_response():
    result = PertoInterface.serial('foo', config)
    assert b'foo|COM' == result

def test_interface_timeout_response_error():
    with pytest.raises(PertoInterface.Fail) as excinfo:
        PertoInterface.serial('foo', {**config,
            'serial_cfg': {
                'file': tmp.name,
                'file_pointer': tmp,
                'serial_class': FakeSerialLazy,
                'serial': {
                    'port': 'COM'
                },
                'timeout': {
                    'between': 0.0001,
                    'cmd': 0.0001,
                    'response': 0.0001
                }
            }
        })
    assert "timeout response" in str(excinfo.value)

def test_interface_unset_error():
    with pytest.raises(PertoInterface.Error) as excinfo:
        PertoInterface.serial('foo', {})
    assert "must be set" in str(excinfo.value)

def test_interface_timeout_first_byte_error():
    with pytest.raises(PertoInterface.Fail) as excinfo:
        PertoInterface.serial('foo', {**config,
            'serial_cfg': {
                'file': tmp.name,
                'file_pointer': tmp,
                'serial_class': FakeSerialLazy,
                'serial': {
                    'port': 'COM'
                },
                'timeout': {
                    'between': 0.0001,
                    'cmd': 0.0001,
                    'ack': 0.0001
                }
            }
        })
    assert "timeout first byte" in str(excinfo.value)

def test_interface_prefix():
    result = PertoInterface.serial('foo', {**config,
        'handler_cfg': {
            'prefix': b'foo|COM'
        }
    })
    assert result == b'foo|COM'

def test_interface_prefix_error():
    result = PertoInterface.serial('foo', {**config,
        'handler_cfg': {
            'prefix': 'foo|COM'
        }
    })
    assert result == b'foo|COM'

def test_interface_suffix():
    result = PertoInterface.serial('foo', {**config,
        'handler_cfg': {
            'suffix': b'foo|COM'
        }
    })
    assert result == b'foo|COM'

def test_interface_suffix_error():
    PertoInterface.serial('foo', {**config,
        'handler_cfg': {
            'suffix': 'foo|COM'
        }
    })
    assert b'foo|COM'

def test_interface_hash():
    result = PertoInterface.serial(['foo', 'foo'], {**config,
        'serial_cfg': {
            'serial_class': FakeSerialHasher,
            'serial': {
                'port': 'COM'
            },
            'timeout': {
                'between': 0.0001,
                'cmd': 0.0001,
            }
        },
        'handler_cfg': {
            'hash': FakeSerialHasher.hasher
        }
    })
    assert result == b'foofoo'

def test_interface_hash_error():
    result = PertoInterface.serial(['foo', 'bar'], {**config,
        'serial_cfg': {
            'serial_class': FakeSerialHasher,
            'serial': {
                'port': 'COM'
            },
            'timeout': {
                'between': 0.0001,
                'cmd': 0.0001,
            }
        },
        'handler_cfg': {
            'hash': FakeSerialHasher.hasher
        }
    })
    assert result == b'foobar'
