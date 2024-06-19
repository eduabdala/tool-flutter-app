from time import time, sleep

DEFAULT_ACK = b'\x06'
DEFAULT_NACK = b'\x15'

class PertoInterface():
    """
    TODO: tests
    TODO: timeout cmd
    TODO: organize
    """
    class Error(Exception):
        pass

    class Fail(Exception):
        pass

    @staticmethod
    def serial(buffer, config):
        '''
        serial send and receive.

        return: response
        '''
        com = PertoInterface.__Serial()
        return com.use(config).send(buffer)

    @staticmethod
    def serial_with_tries(buffer, config):
        '''
        serial send and receive with number of tries in case of exception.

        return: response
        '''
        com = PertoInterface.__Serial()
        for i in range(config['serial_cfg']['tries']['number_of_tries']):
            PertoInterface.log_into_file("ATTEMPT "+str(i+1)+"/"+str(config['serial_cfg']['tries']['number_of_tries']), config, 1)
            try:
                return com.use(config).send(buffer)
            except Exception as e:
                PertoInterface.log_into_file(e, config, 1)
                sleep(config['serial_cfg']['tries']['time_between_tries'])
                if i < config['serial_cfg']['tries']['number_of_tries'] - 1:
                    continue
                else:
                    raise e

    @staticmethod
    def serial_write(buffer, config):
        '''
        serial only send.

        return: same buffer 
        '''
        com = PertoInterface.__Serial()
        com.use(config).serial.write(buffer)
        return buffer

    @staticmethod
    def file_write(buffer, config):
        '''
        file only save.

        return: same buffer 
        '''
        with open(config['file'], 'bw+') as file:
            file.write(buffer)
            return buffer

    @staticmethod
    def log_into_file(message, config, mode=None):
        '''
        log into file configured

        return: logged message
        '''
        if 'logger' in config:
            if mode == 1:
                config['logger'].logger.debug(message)
            else:
                config['logger'].logger.debug(config['logger'].convert_bytes_to_ascii(message))
                config['logger'].logger.debug(config['logger'].convert_bytes_to_hex_string(message))
        return message

    class __Serial():

        def use(self, config: dict):
            try:
                self.config = config['serial_cfg']
                self.handler = config['handler_cfg']
                self.serial = self.config['serial_class']
                self.serial = self.serial(**self.config['serial'])
                self.serial.close()
                if 'ack' in self.config['timeout']:
                    self.ack_flag = True
                    if 'ack_byte' in self.config['timeout']:
                        self.ack_to_test = self.config['timeout']['ack_byte']
                    else:
                        self.ack_to_test = DEFAULT_ACK
                    if 'nack_byte' in self.config['timeout']:
                        self.nack_to_test = self.config['timeout']['nack_byte']
                    else:
                        self.nack_to_test = DEFAULT_NACK
                    if self.config['timeout'].get('return_ack', None) is True:
                        self.return_ack = True
                    else:
                        self.return_ack = False
                else:
                    self.ack_flag = False
                    self.return_ack = False
                if 'response' in self.config['timeout']:
                    self.response_flag = True
                else:
                    self.response_flag = False
                if 'prefix' in self.handler:
                    self.prefix = True
                else:
                    self.prefix = False
                if 'suffix' in self.handler:
                    self.suffix = True
                else:
                    self.suffix = False
                if 'hash' in self.handler:
                    self.hash = True
                else:
                    self.hash = False
            except KeyError as key:
                raise PertoInterface.Error(f"Interface '{key}' must be set.")
            return self

        def serial_write(self, buffer) -> bytes:
            PertoInterface.log_into_file(buffer, self.config)
            self.serial.write(buffer)
            return buffer

        def serial_read(self) -> bytes:
            res = bytes()
            if self.ack_flag:
                res += self.check_ack()
            if self.response_flag:
                self.check_response()
            if self.prefix:
                res += self.read_bytes(self.check_prefix)
            if self.suffix:
                res += self.read_bytes(self.check_suffix)
            else:
                res += self.read_bytes()
            if self.hash:
                self.hash_bytes = self.handler['hash'](res[len(self.ack_to_test):] if self.ack_flag else res)
                res += self.read_bytes(self.check_hash)
            PertoInterface.log_into_file(res, self.config)
            if self.return_ack:
                self.send_ack()
            return res

        def read_bytes(self, stop_condition=lambda x: False):
            buffer = bytes()
            last_byte_time = time()
            while (last_byte_time + self.config['timeout']['between']) > time():
                if self.serial.inWaiting() > 0:
                    last_byte_time = time()
                    buffer += self.serial.read(1)
                    if(stop_condition(buffer)):
                        break
            return buffer

        def check_prefix(self, buffer):
            if buffer[-len(self.handler['prefix']):] == self.handler['prefix']:
                return True
            else:
                return False

        def check_suffix(self, buffer):
            if buffer[-len(self.handler['suffix']):] == self.handler['suffix']:
                return True
            else:
                return False

        def check_hash(self, buffer):
            if buffer[-len(self.hash_bytes):] == self.hash_bytes:
                return True
            else:
                return False

        def check_response(self):
            PertoInterface.log_into_file("WAITING RESPONSE...", self.config, 1)
            response_timeout = time() + self.config['timeout']['response']
            while self.serial.inWaiting() <= 0:
                if response_timeout <= time():
                    raise PertoInterface.Fail('timeout response.')
            PertoInterface.log_into_file("RESPONSE RECEIVED", self.config, 1)

        def check_ack(self) -> bytes:
            ack = bytes()
            first_byte_timeout = time() + self.config['timeout']['ack']
            PertoInterface.log_into_file("WAITING ACK/NACK...", self.config, 1)
            while self.serial.inWaiting() <= 0:
                if first_byte_timeout <= time():
                    raise PertoInterface.Fail('timeout first byte.')
            ack = self.serial.read(1)
            if ack == self.ack_to_test:
                PertoInterface.log_into_file("ACK RECEIVED", self.config, 1)
            elif ack == self.nack_to_test:
                PertoInterface.log_into_file("NACK RECEIVED", self.config, 1)
            else:
                raise PertoInterface.Error("Ack "+ack.hex().upper()+" received is different from ack "+self.ack_to_test.hex().upper()+" and nack "+self.nack_to_test.hex().upper()+" configured")
            return ack

        def send_ack(self):
            PertoInterface.log_into_file("SENDING ACK...", self.config, 1)
            return self.serial_write(self.ack_to_test)

        def send(self, buffer) -> bytes:
            try:
                self.serial.open()

                self.serial_write(buffer)

                res = self.serial_read()

                self.serial.close()
            except Exception as e:
                self.serial.close()
                raise e
            return res
            