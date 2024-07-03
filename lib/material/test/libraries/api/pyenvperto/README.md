# Py Env Perto

[![pipeline status](http://git.edsperto.com/componentspython/pyenvperto/badges/main/pipeline.svg)](http://git.edsperto.com/componentspython/pyenvperto/-/commits/main)
[![coverage report](http://git.edsperto.com/componentspython/pyenvperto/badges/main/coverage.svg)](http://git.edsperto.com/componentspython/pyenvperto/-/commits/main)

## Features ##

 * TDD Writed.
 * Simple and uncomplicated.

## Usage ##

#### How to test ####

Run the following commands to download, develop, or test the library's source code.

```
git clone git@git.edsperto.com:componentspython/pyenvperto.git
make deps-build
make unit-test
```

### How to use ###

run the following command to install.

```
git submodule add git@git.edsperto.com:componentspython/pyenvperto.git
```

Write a dotenv file.

```INI
# My simple message
hello=Hi there! 
```

Follow the example of using the library.

```python
from Dotenv import Dotenv

env = Dotenv.load_file('.env')

print(env.hello)
```
