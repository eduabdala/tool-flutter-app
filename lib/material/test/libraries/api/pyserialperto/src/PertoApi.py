class PertoApi():
    """Interface for sending commands via interface.

    usage:
        perto = (PertoApi()
            .setHandler.prefix(b'')
            .setHandler.suffix(b'')
            .setHandler.strip(PertoStrip.none)
            .setHandler.hash(ErrorDetect.bcc8)
            .setHandler(PertoHandler.simple)
            .setInterface.port('COM3')
            .setInterface.baudrate(19200)
            .setInterface.serial_class(Serial)
            .setInterface(PertoInterface.serial)
            .setPipeline(PertoCommand.pipeline)
        )

    raise:
        PertoApi.Error: when invalid config recevied.

    """
    __version__ = "2.1.0"
    __author__ = "Rodrigo Dornelles"
    __contact__ = "rodrigo.dornelles@perto.com.br"
    __copyright__ = "Copyright 2022, Perto S.A"

    class Error(Exception):
        pass

    class __Invoke(dict):
        """Class transform attribute into magic method.
        feats: return as dict, add values to invoking dict, change attribute.
        """
        def __init__(self, other, attribute_func, attribute_cfg):
            #init linker
            self.__atrr_func = "_{:s}{:s}".format(type(other).__name__, attribute_func)
            self.__atrr_cfg = "_{:s}{:s}".format(type(other).__name__, attribute_cfg)
            self.__other = other
            # start configs
            if not hasattr(self.__other, self.__atrr_cfg):
                setattr(self.__other, self.__atrr_cfg, dict())

        def __call__(self, value):
            setattr(self.__other, self.__atrr_func, value)
            return self.__other

        def __invoke(self, name, param1, param2):
            # get atual configs
            cfgs = getattr(self.__other, self.__atrr_cfg)

            #adjust configs
            if param2 is None: # one paramter
                cfgs[name] = param1
            else: # two paramters
                if not name in cfgs:
                    cfgs[name] = dict()
                cfgs[name][param1] = param2

            #save configs
            setattr(self.__other, self.__atrr_cfg, cfgs)

            return self.__other

        def __getattr__(self, name):
            return lambda p1, p2=None: self.__invoke(name, p1, p2)

    def __copy__(self):
        raise self.Error("please uses 'deepcopy' instead of 'copy'")

    def __eval(self, cmd):
        cmd = self.__handler_func(cmd, {
            "handler_cfg": self.__handler_cfg,
            "serial_cfg": self.__interface_cfg,
            "serial_func": self.__interface_func
        })
        del self.__then
        return cmd

    @property
    def setInterface(self):
        return PertoApi.__Invoke(self, '__interface_func', '__interface_cfg')

    @property
    def setHandler(self):
        return PertoApi.__Invoke(self, '__handler_func', '__handler_cfg')

    def setPipeline(self, func):
        self.__pipeline_func = func
        return self

    def cmd(self, command):
        # verify configs
        klass = type(self)
        if not hasattr(self, f'_{klass.__name__}__handler_func'):
            raise klass.Error('Handler must be set.')
        if not hasattr(self, f'_{klass.__name__}__pipeline_func'):
            raise klass.Error('Pipeline must be set.')
        if not hasattr(self, f'_{klass.__name__}__interface_func'):
            raise klass.Error('Interface must be set.')
        if not callable(self.__handler_func):
            raise klass.Error('Handler must be callable.')
        if not callable(self.__pipeline_func):
            raise klass.Error('Pipeline must be callable.')
        if not callable(self.__interface_func):
            raise klass.Error('Interface must be callable.')
        # build pipeline
        self.__then = self.__pipeline_func(lambda cmd: self.__eval(cmd))
        self.__then = self.__then(command)
        # return pipeline
        return self.__then

    @property
    def then(self):
        klass = type(self)
        if not hasattr(self, f'_{klass.__name__}__then'):
            raise klass.Error('There is no command in progress.')
        return self.__then
