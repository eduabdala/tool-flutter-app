# pySerialPerto

[![pipeline status](http://git.gdservers.com.br/componentspython/pyserialperto/badges/main/pipeline.svg)](http://git.gdservers.com.br/componentspython/pyserialperto/-/commits/main)
[![coverage report](http://git.gdservers.com.br/componentspython/pyserialperto/badges/main/coverage.svg)](http://git.gdservers.com.br/componentspython/pyserialperto/-/commits/main)

## Features ##

 * TDD Writed.
 * Componentized.
 * Generic interface.
 * Mutable configuration at any time.
 * Assembling commands in the form of a pipeline.

## Usage ##

#### How to test ####

Run the following commands to download, develop, or test the library's source code.

```
git clone git@git.gdservers.com.br:componentspython/pyserialperto.git
pip install -r requirements.txt
pytest
```

### How to use ###

run the following command to install.

```
git submodule add git@git.gdservers.com.br:componentspython/pyserialperto.git
```

Follow the example of using the library.

```python
#Import all deps
from serial import Serial as ThirdySerial
from pyserialperto import *

#Interface Config
AntiSkimming = (PertoApi()
    .setHandler.prefix(b'\x02')
    .setHandler.suffix(b'\x03')
    .setHandler.hash(ErrorDetect.bcc8)
    .setHandler.strip(Strip.regex(rb'\x02(.*)\x03'))
    .setHandler(PertoHandler.simple)
    .setInterface.timeout('ack', 0.25)
    .setInterface.timeout('cmd', 0.2)
    .setInterface.timeout('between', 0.1)
    .setInterface.serial('port', 'COM3')
    .setInterface.serial('baudrate', 19200)
    .setInterface.serial_class(ThirdySerial)
    .setInterface(PertoInterface.serial)
    .setPipeline(PertoCommand.pipeline)
)

#Output: True
AntiSkimming.cmd('V0').expect(b'VF15GXS03').non_fail().send()
```
