"""Environment variables loader
"""
import os
import re
import json
from pathlib import Path

class Dotenv():
    """Environment builder
    """

    @staticmethod
    def load_str(txt_str:str):
        """Load environment variables from string
        """
        return Dotenv.__Env(txt_str)

    @staticmethod
    def load_file(txt_file:str):
        """Load environment variables from file
        """
        try:
            return Dotenv.__Env(open(txt_file,'r', encoding="utf-8").read())
        except FileNotFoundError:
            return Dotenv.__Env('')

    @staticmethod
    def load_deep(txt_file: str, depth: int):
        """Load environment variables from root depth file

        Args:
            txt_file (str): file name
            depth (int): each parent folder
        """
        path = Path(os.path.dirname(os.path.abspath(__file__))).resolve()
        while depth > 0:
            try:
                file = f'{path}/{txt_file}'
                return Dotenv.__Env(open(file, 'r', encoding="utf-8").read())
            except FileNotFoundError:
                path = path.parent
                depth -= 1
        return Dotenv.__Env('')

    class Error(Exception):
        """Environment handler
        """

    class __Env():
        """Environment hashmap
        """
        def __init__(self, txtini:str):
            self.__env = dict(os.environ) # Safety
            for line in txtini.split("\n"):
                token = re.findall(r'^([a-zA-Z0-9_]+)=(.*)$', line)
                if len(token) == 1: # [(key, value)]
                    self.__env[token[0][0]] = token[0][1]

        def __getattr__(self, name):
            """Magic method that simulates env-vars as properties
            """
            return self.__env[name]

        def __str__(self):
            """Dumps environment variables as json.
            """
            return json.dumps(self.__env)

        def get_required(self, name):
            """Returning env-vars or fatal exit.
            """
            if not name in self.__env:
                raise Dotenv.Error(f"environment variable '{name}' is required.")
            return self.__env[name]

        def get_optional(self, name, default_value=None):
            """Returning env-vars or a default value.
            """
            if not isinstance(default_value, (str, type(None))):
                raise Dotenv.Error(f"default_value '{name}' must be string or None.")
            if name in self.__env:
                return self.__env[name]
            return default_value
