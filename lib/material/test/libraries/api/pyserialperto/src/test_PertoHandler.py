from PertoHandler import PertoHandler
import pytest

config = {
    'handler_cfg': {
        'hash': lambda x: b'\x42',
        'strip': lambda x: x[1:],
        'prefix': b'\x04\x02',
        'suffix': b'\x03'
    },
    'serial_func': lambda x, y: x,
    'serial_cfg': {}
}

def test_handler_simple():
    result = PertoHandler.simple('foo', config)
    assert result == b'\x02foo\x03\x42'

def test_handler_prefix_len_cmd_hash():
    result = PertoHandler.prefix_len_cmd_hash('foo', config)
    assert result == b'\x02\x03foo\x42'

def test_handler_raw():
    result = PertoHandler.raw('foo', config)
    assert result == b'foo'

def test_handler_error_callable():
    with pytest.raises(PertoHandler.Error) as excinfo:
        PertoHandler.simple('foo', {**config,
            'handler_cfg': {'hash': 5}
        })
    assert "must be callable" in str(excinfo.value)

def test_handler_simple_error_unset():
    with pytest.raises(PertoHandler.Error) as excinfo:
        PertoHandler.simple('foo', {'handler_cfg': {}})
    assert "must be set" in str(excinfo.value)

def test_handler_sankyo_callable():
    with pytest.raises(PertoHandler.Error) as excinfo:
        PertoHandler.prefix_len_cmd_hash('foo', {**config,
            'handler_cfg': {'hash': 5}
        })
    assert "must be callable" in str(excinfo.value)

def test_handler_sankyo_error_unset():
    with pytest.raises(PertoHandler.Error) as excinfo:
        PertoHandler.prefix_len_cmd_hash('foo', {'handler_cfg': {}})
    assert "must be set" in str(excinfo.value)
