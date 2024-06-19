from Strip import Strip
import pytest

def test_none():
    result = Strip.none()('fobarz')
    assert result == 'fobarz'

def test_regex_or_pass():
    result = Strip.regex_or_pass(r'\[(.*)\]')('[fobarz]')
    assert result == 'fobarz'

def test_regex_or_pass_multi():
    result = Strip.regex_or_pass(r'\[(.*)-(.*)\]')('[foo-bar]')
    assert 'foobar' == result

def test_regex_or_pass_ignore():
    result = Strip.regex_or_pass(r'\[(.*)\]')('an error detected')
    assert result == 'an error detected'

def test_regex():
    result = Strip.regex(r'\[(.*)\]')('[fobarz]')
    assert result == 'fobarz'

def test_regex_multi():
    result = Strip.regex(r'\[(.*)-(.*)\]')('[foo-bar]')
    assert result == 'foobar'

def test_regex_bytes():
    result = Strip.regex(rb'\[(.*)\]')(b'[fobarz]')
    assert result == b'fobarz'

def test_regex_bytes_multi():
    result = Strip.regex(rb'\[(.*)-(.*)\]')(b'[foo-bar]')
    assert result == b'foobar'

def test_regex_error_type():
    with pytest.raises(Strip.Error) as excinfo:
        Strip.regex(r'\[(.*)\]')(5)
    assert "types don't match" in str(excinfo.value)

def test_regex_error_match():
    with pytest.raises(Strip.Error) as excinfo:
        Strip.regex(r'\[(.*)\]')('an error detected')
    assert "not matching" in str(excinfo.value)

def test_regex_bug_001():
    result = Strip.regex(rb'^\x02(.+?)\x03')(b'\x02\x66\x6F\x6F\x62\x61\x72\x03\x03')
    assert result == b'foobar'

def test_regex_bug_002():
    result = Strip.regex(rb'^\x02(.+?)\x03')(b'\x02\x66\x6F\x6F\x62\x61\x72\x03\x5C')
    assert result == b'foobar'

def test_regex_bug_003():
    result = Strip.regex(rb'^\x02(.+?)\x03')(b'\x02\x02\x03\x03\x03\x03\x03')
    assert result == b'\x02'

def test_regex_bug_004():
    result = Strip.regex(rb'^\x02(.+?)\x03')(b'\x02\x03\x05\x03\x00')
    assert result == b'\x03\x05'
