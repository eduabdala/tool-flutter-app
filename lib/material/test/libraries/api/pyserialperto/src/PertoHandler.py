class PertoHandler():
    class Error(Exception):
        pass

    @staticmethod
    def simple(data, config):
        return PertoHandler.prefix_cmd_suffix_hash(data, config)

    @staticmethod
    def prefix_cmd_suffix_hash(data, config):
        """
        Comunicação simples round trip re reply.
            -> [prefix][cmd][suffix][hash]
            <- [response]

        raises:
            PertoHandler.Error when invalid config 
        """
        try:
            assert callable(config['handler_cfg']['hash']), 'hash callable'
            assert callable(config['handler_cfg']['strip']), 'strip callable'
            assert isinstance(config['handler_cfg']['prefix'], bytes), 'prefix encoded'
            assert isinstance(config['handler_cfg']['suffix'], bytes), 'suffix encoded'
            data = bytes(data.encode() if isinstance(data, str) else data)
            data = config['handler_cfg']['prefix'] + data            # add prefix
            data = data + config['handler_cfg']['suffix']            # add suffix
            data = data + config['handler_cfg']['hash'](data)        # add hash
            data = config['serial_func'](data, config)               # send and receive
            data = config['handler_cfg']['strip'](data)              # strip received
        except KeyError as key:
            raise PertoHandler.Error(f"Handler config {key} must be set.")
        except AssertionError as error:
            error = str(' must be '.join(str(error).split(' ')))
            raise PertoHandler.Error(f"Handler config {error}.")

        return data


    @staticmethod
    def prefix_len_cmd_hash(data, config):
        """
        Comunicação utilizada pela sankyo.
            -> [prefix][len][cmd][hash]
            <- [response]

        raises:
            PertoHandler.Error when invalid config 
        """
        try:
            assert callable(config['handler_cfg']['hash']), 'hash callable'
            assert callable(config['handler_cfg']['strip']), 'strip callable'
            assert isinstance(config['handler_cfg']['prefix'], bytes), 'prefix encoded'
            data = bytes(data.encode() if isinstance(data, str) else data)
            data = len(data).to_bytes(1, 'little') + data            # add size
            data = config['handler_cfg']['prefix'] + data            # add prefix
            data = data + config['handler_cfg']['hash'](data)        # add hash
            data = config['serial_func'](data, config['serial_cfg']) # send and receive
            data = config['handler_cfg']['strip'](data)              # strip received
        except KeyError as key:
            raise PertoHandler.Error(f"Handler config {key} must be set.")
        except AssertionError as error:
            error = str(' must be '.join(str(error).split(' ')))
            raise PertoHandler.Error(f"Handler config {error}.")
        return data

    @staticmethod
    def raw(data, config):
        data = bytes(data.encode() if isinstance(data, str) else data) #encode?
        data = config['serial_func'](data, config['serial_cfg']) #send and receive
        return data #end!