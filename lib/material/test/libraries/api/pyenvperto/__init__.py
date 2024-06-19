'''Stupid library to load environment variables.

usage:
    from Dotenv import Dotenv

    env = Dotenv.load_file('.env')
    
    print(env.hello)

raise:
    KeyError
'''
# Notice
__version__ = "1.0.0" #pragma: no cover
__copyright__ = "Copyright 2022, Perto S.A" #pragma: no cover

# Import fixture
import sys, os #pragma: no cover
sys.path.append(os.path.abspath(os.path.dirname(__file__)+'/src')) #pragma: no cover

# PERTO COMPONENTS
from .src.dotenv import Dotenv #pragma: no cover

# Clean up
del sys, os # pragma:no cover
