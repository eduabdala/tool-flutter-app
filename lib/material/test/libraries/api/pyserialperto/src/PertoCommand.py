import itertools, re

class PertoCommand():
    """!
    Command builder in pipeline format.

    usage:
        cmd = PertoCommand.pipeline(
            sender = lambda cmd: mySender(cmd)
        )

        result1 = cmd('v').param(0).regex('\\d+\\.\\d+\\.\\d+').non_fail().send()
        result2 = cmd('foo').expect('bar').non_fail().send()
        result3 = cmd('foz').expect('baz').send()
        result2 = cmd('for').send()

    raise:
        PertoCommand.Fail:
            When the command gets unexpected result.

        PertoCommand.Error:
            When using the library incorrectly.
    """
    __version__ = "1.1.0"
    __author__ = "Rodrigo Dornelles"
    __contact__ = "rodrigo.dornelles@perto.com.br"
    __copyright__ = "Copyright 2022, Perto S.A"

    @staticmethod
    def pipeline(sender):
        pipeline = PertoCommand.__Pipeline(sender)
        return pipeline.create

    class Error(Exception):
        pass

    class Fail(Exception):
        pass

    class __Pipeline():
        def __init__(self, sender):
            self.__sender = sender

        def __call(self):
            return self.__sender(self.__cmd)

        def __non_fault(self, func):
            try:
                result = func()
            except PertoCommand.Fail:
                return False
            return True

        def __encode(self, data):
            return bytes(data.encode() if isinstance(data, str) else data)

        def __decode(self, data):
            return str(data.decode() if isinstance(data, bytes) else data)

        def __find(self, func, expression):
            result = func()
            search = re.findall(expression, self.__decode(result))
            search = ''.join(tuple(itertools.chain(*search)))
            if not len(search):
                raise PertoCommand.Fail(f"Failed, search by /{expression}/ but receveid '{result}'")
            return search

        def __unexpected_fault(self, func, expected):
            result = func()
            if self.__encode(result) != self.__encode(expected): # compare as some type (bytes)
                raise PertoCommand.Fail(f"Failed, expected '{expected}' but received '{result}'")
            return True

        def __unmatch_fault(self, func, expression):
            result = func()
            if not re.match(expression, self.__decode(result)): # compare as type string
                raise PertoCommand.Fail(f"Failed, matching /{expression}/ but received '{result}'")
            return True

        def create(self, cmd):
            self.__cmd = self.__encode(cmd)
            self.__pipeline = lambda: self.__call()
            return self

        def param(self, cmd):
            self.__cmd += self.__encode(cmd)
            return self

        def custom(self, func):
            non_loooping_function = self.__pipeline
            def fail(txt):
                raise PertoCommand.Fail(txt)
            if func.__code__.co_argcount == 2:
                self.__pipeline = lambda: func(non_loooping_function(), fail)
            else:
                self.__pipeline = lambda: func(non_loooping_function())
            return self

        def expect(self, expected):
            non_loooping_function = self.__pipeline
            self.__pipeline = lambda: self.__unexpected_fault(non_loooping_function, expected)
            return self

        def find(self, search):
            non_loooping_function = self.__pipeline
            self.__pipeline = lambda: self.__find(non_loooping_function, search)
            return self

        def regex(self, expected):
            non_loooping_function = self.__pipeline
            self.__pipeline = lambda: self.__unmatch_fault(non_loooping_function, expected)
            return self

        def non_fail(self):
            non_loooping_function = self.__pipeline
            self.__pipeline = lambda: self.__non_fault(non_loooping_function)
            return self

        def send(self):
            if not callable(self.__pipeline):
                raise PertoCommand.Error("Error, empty command.")

            while callable(self.__pipeline):
                self.__pipeline = self.__pipeline() 

            return self.__pipeline
