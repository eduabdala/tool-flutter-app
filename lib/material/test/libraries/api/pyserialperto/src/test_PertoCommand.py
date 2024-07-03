from PertoCommand import PertoCommand
import pytest, codecs

#rotate 13 encode/decode
def rot13(data):
    return codecs.encode(data.decode(), 'rot_13')

cmd = PertoCommand.pipeline(lambda c: rot13(c))

def test_cmd_send():
    assert cmd('foo').send() == 'sbb'

def test_cmd_expect_send():
    assert cmd('foo').expect('sbb').send() == True

def test_cmd_regex_send():
    assert cmd('foo').regex(r's[b]{2}').send() == True

def test_cmd_find_send():
    assert cmd('foobarz').find(r'bon[e]{1}').send() == 'bone'

def test_cmd_custom_send():
    assert cmd('foo').custom(lambda x: x.upper()).send() == 'SBB'

def test_cmd_expect_non_fail_send():
    assert cmd('foo').expect('sbb').non_fail().send() == True

def test_cmd_regex_non_fail_send():
    assert cmd('foo').regex(r's[b]{2}').non_fail().send() == True

def test_cmd_expect_non_fail_send_false():
    assert cmd('baz').expect('sbb').non_fail().send() == False

def test_cmd_regex_non_fail_send_false():
    assert cmd('baz').regex(r's[b]{2}').non_fail().send() == False

def test_cmd_param_send():
    assert cmd('f').param('o').param('o').send() == 'sbb'

def test_cmd_param_expect_send():
    assert cmd('f').param('o').param('o').expect('sbb').send() == True

def test_cmd_param_regex_send():
    assert cmd('f').param('o').param('o').regex(r's[b]{2}').send() == True

def test_cmd_param_custom_send():
    assert cmd('f').param('o').param('o').custom(lambda x: x.upper()).send() == 'SBB'

def test_cmd_param_expect_non_fail_send():
    assert cmd('f').param('o').param('o').expect('sbb').non_fail().send() == True

def test_cmd_param_regex_non_fail_send():
    assert cmd('f').param('o').param('o').regex(r's[b]{2}').non_fail().send() == True

def test_cmd_param_expect_non_fail_send_false():
    assert cmd('b').param('a').param('z').expect('sbb').non_fail().send() == False

def test_cmd_param_regex_non_fail_send_false():
    assert cmd('b').param('a').param('z').regex(r's[b]{2}').non_fail().send() == False

def test_cmd_param_custom_non_fail_send():
    assert cmd('f').param('o').param('o').custom(lambda x, fail: fail(x)).non_fail().send() == False

def test_cmd_expect_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('baz').expect('sbb').send()
    assert "expected" in str(excinfo.value)

def test_cmd_regex_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('baz').regex(r's[b]{2}').send()
    assert "matching" in str(excinfo.value)

def test_cmd_find_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('baz').find(r's[b]{2}').send()
    assert "search by" in str(excinfo.value)

def test_cmd_param_expect_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('b').param('a').param('z').expect('sbb').send()
    assert "expected" in str(excinfo.value)

def test_cmd_param_regex_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('b').param('a').param('z').regex(r's[b]{2}').send()
    assert "matching" in str(excinfo.value)

def test_cmd_error_empty():
    with pytest.raises(PertoCommand.Error) as excinfo:
        pipeline = cmd("foo")
        pipeline.send()
        pipeline.send()
    assert "empty" in str(excinfo.value)

def test_cmd_custom_send_failed():
    with pytest.raises(PertoCommand.Fail) as excinfo:
        cmd('foo').custom(lambda x, fail: fail(x)).send()
    assert "sbb" in str(excinfo.value)
