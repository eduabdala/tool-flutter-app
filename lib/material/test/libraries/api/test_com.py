import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(SCRIPT_DIR))

from api import pertoapi

args = sys.argv
pertoapi.setInterface.serial('port', args[1])
print(pertoapi.cmd(args[2]).send())
