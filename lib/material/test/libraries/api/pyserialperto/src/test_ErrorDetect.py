from ErrorDetect import ErrorDetect
import pytest

def test_error_detect_bcc8():
    assert b'\x67' == ErrorDetect.bcc8(b"\x02foo\x03")

def test_error_detect_bcc8_len_le():
    assert b'\x64' == ErrorDetect.bcc8(b"\x02foo\x03", 4)

def test_error_detect_bcc8_len_eq():
    assert b'\x67' == ErrorDetect.bcc8(b"\x02foo\x03", 5)

def test_error_detect_bcc16():
    assert b'\x6E\x09' == ErrorDetect.bcc16(b"\x02foo\x03")

def test_error_detect_bcc16_len_le():
    assert b'\x6D\x09' == ErrorDetect.bcc16(b"\x02foo\x03", 4)

def test_error_detect_bcc16_len_eq():
    assert b'\x6E\x09' == ErrorDetect.bcc16(b"\x02foo\x03", 5)

def test_error_detect_crc16_xmodem():
    assert b'\xA6\xE5' == ErrorDetect.crc16_xmodem(b"\x02foo\x03")

def test_error_detect_crc16_xmodem_len_le():
    assert b'\x42\xFE' == ErrorDetect.crc16_xmodem(b"\x02foo\x03", 4)

def test_error_detect_crc16_xmodem_len_eq():
    assert b'\xA6\xE5' == ErrorDetect.crc16_xmodem(b"\x02foo\x03", 5)

def test_error_detect_bcc8_len_ge_error():
    with pytest.raises(ValueError) as excinfo:
        ErrorDetect.bcc8(b"\x02foo\x03", 6)
    assert "'size' is greater than 'data' lenght" in str(excinfo.value)

def test_error_detect_crc16_xmodem_len_ge_error():
    with pytest.raises(ValueError) as excinfo:
        ErrorDetect.crc16_xmodem(b"\x02foo\x03", 6)
    assert "'size' is greater than 'data' lenght" in str(excinfo.value)

def test_error_detect_crc16_fitec():
    assert b'\xDF\x12' == ErrorDetect.crc16_fitec(b"\x02foo\x03")

def test_error_detect_crc16_fitec_len_le():
    assert b'\x7A\x1B' == ErrorDetect.crc16_fitec(b"\x02foo\x03", 4)

def test_error_detect_crc16_fitec_len_eq():
    assert b'\xDF\x12' == ErrorDetect.crc16_fitec(b"\x02foo\x03", 5)

def test_error_detect_crc16_fitec_len_ge_error():
    with pytest.raises(ValueError) as excinfo:
        ErrorDetect.crc16_fitec(b"\x02foo\x03", 6)
    assert "'size' is greater than 'data' lenght" in str(excinfo.value)
