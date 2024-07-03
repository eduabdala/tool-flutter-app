from copy import deepcopy as copy
from copy import copy as wrongcopy
from PertoApi import PertoApi
import pytest, base64

def check(data):
    return base64.b64encode(data)

def handler(data, config):
    data = data.encode()
    data = config['handler_cfg']['prefix'] + data
    data = data + config['handler_cfg']['suffix']
    data = data + config['handler_cfg']['hash'](data)
    return config['serial_func'](data, config['serial_cfg'])

def serial(data, config):
    port = config['serial']['port']
    timeout = config['timeout']
    return (f"SERIAL[{data.decode()}]T[{timeout}]{port}").encode()

def pipeline(func):
    class fakePipeLine():
        def cmd(self, c):
            self.c = c
            return self

        def send(self):
            return func(f"cmd:{self.c}")

    pipeline = fakePipeLine()
    return lambda cmd: pipeline.cmd(cmd)

perto = (PertoApi()
    .setInterface(serial)
    .setInterface.timeout(100)
    .setInterface.serial('port', '')
    .setHandler(handler)
    .setHandler.hash(check)
    .setHandler.prefix(b'\x02')
    .setHandler.suffix(b'\x03')
    .setPipeline(pipeline)
)

def test_interface_send():
    result = perto.cmd('foo').send()
    assert result == b'SERIAL[\x02cmd:foo\x03AmNtZDpmb28D]T[100]'

def test_interface_then():
    perto.cmd('foo')
    result = perto.then.send()
    assert result == b'SERIAL[\x02cmd:foo\x03AmNtZDpmb28D]T[100]'

def test_interface_port():
    perto_tmp = copy(perto).setInterface.serial('port', 'COM')
    result = perto_tmp.cmd('foo').send()
    assert result == b'SERIAL[\x02cmd:foo\x03AmNtZDpmb28D]T[100]COM'

def test_interface_replace_pfsf_and_send():
    perto_tmp = copy(perto)
    perto_tmp.setHandler.prefix(b'\x04').setHandler.suffix(b'\x05')
    result = perto_tmp.cmd('foo').send()
    assert result == b'SERIAL[\x04cmd:foo\x05BGNtZDpmb28F]T[100]'

def test_interface_handler_callable_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        copy(perto).setHandler(0).cmd('foo')
    assert "Handler must be callable" in str(excinfo.value)

def test_interface_interface_callable_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        copy(perto).setInterface(0).cmd('foo')
    assert "Interface must be callable" in str(excinfo.value)

def test_interface_pipeline_callable_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        copy(perto).setPipeline(0).cmd('foo')
    assert "Pipeline must be callable" in str(excinfo.value)

def test_interface_handler_unset_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        PertoApi().setInterface(0).setPipeline(0).cmd('foo')
    assert "Handler must be set." in str(excinfo.value)

def test_interface_pipeline_unset_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        PertoApi().setHandler(0).setInterface(0).cmd('foo')
    assert "Pipeline must be set." in str(excinfo.value)

def test_interface_interface_unset_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        PertoApi().setHandler(0).setPipeline(0).cmd('foo')
    assert "Interface must be set." in str(excinfo.value)

def test_interface_empty_then_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        result = perto.then
    assert "no command in progress" in str(excinfo.value)

def test_interface_wrong_copy_error():
    with pytest.raises(PertoApi.Error) as excinfo:
        wrongcopy(perto)
    assert "instead" in str(excinfo.value)
