from dotenv import Dotenv
import pytest
import tempfile
import os
import json

ENV_TXT = """
foo1=bar1
foo2= bar2
foo3 =bar3
foo4 = bar4
#foo5=bar5
#foo6= bar6
#foo7 =bar7
#foo8 = bar8
z=z
"""

env_file = open(os.path.dirname(os.path.abspath(__file__)) + '/../.env', 'wb')
env_file.write(ENV_TXT.encode())
env_file.seek(0)

def test_dump():
    env = Dotenv.load_str(ENV_TXT)
    jason = json.loads(str(env))
    assert 'z' == jason['z'] 
    assert 'bar1' == jason['foo1']
    assert ' bar2' == jason['foo2']
    assert len(env._)

def test_get_required():
    env = Dotenv.load_str(ENV_TXT)
    assert 'z' == env.get_required('z')
    assert len(env._)

def test_get_optional():
    env = Dotenv.load_str(ENV_TXT)
    assert 'z' == env.get_optional('z', 'x')
    assert 'x' == env.get_optional('y', 'x')
    assert None == env.get_optional('w')
    assert len(env._)

def test_load_str():
    env = Dotenv.load_str(ENV_TXT)
    assert 'z' == env.z 
    assert 'bar1' == env.foo1
    assert ' bar2' == env.foo2
    assert len(env._)

def test_load_file():
    env = Dotenv.load_file(env_file.name)
    assert 'z' == env.z 
    assert 'bar1' == env.foo1
    assert ' bar2' == env.foo2
    assert len(env._)

def test_load_deep():
    env = Dotenv.load_deep('.env', 2)
    assert 'z' == env.z 
    assert 'bar1' == env.foo1
    assert ' bar2' == env.foo2
    assert len(env._)

def test_load_file_ingore():
    env = Dotenv.load_file(env_file.name+'_nonexist')
    assert len(env._)

def test_load_deep_error():
    env = Dotenv.load_deep('.env', 1)
    for key in ['foo1', 'foo2', 'foo3', 'foo4', 'foo5', 'foo6', 'foo7', 'foo8', 'z']:
        with pytest.raises(KeyError) as excinfo:
            getattr(env, key)
        assert key in str(excinfo.value)

def test_load_error():
    env = Dotenv.load_file(env_file.name)
    for key in ['foo3', 'foo4', 'foo5', 'foo6', 'foo7', 'foo8']:
        with pytest.raises(KeyError) as excinfo:
            getattr(env, key)
        assert key in str(excinfo.value)

def test_optional_type_error():
    env = Dotenv.load_str(ENV_TXT)
    with pytest.raises(Dotenv.Error) as excinfo:
        env.get_optional('z', 5)
    assert 'string or None' in str(excinfo.value)

def test_required_error():
    env = Dotenv.load_str(ENV_TXT)
    with pytest.raises(Dotenv.Error) as excinfo:
        env.get_required('abc')
    assert 'required' in str(excinfo.value)
