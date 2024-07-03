from robot.api.deco import keyword
from api import DateHandler
import time

@keyword("Eu armazeno o horário atual")
def store_time():
    return DateHandler.get_current_time()

@keyword("Eu obtenho a diferença entre os tempos '${timer1}' e '${timer2}'")
def get_time_difference(timer1, timer2):
    return timer1 - timer2

@keyword("Eu obtenho a soma entre os tempos '${timer1}' e '${timer2}'")
def get_time_plus(timer1, timer2):
    return timer1 + timer2

@keyword("Eu converto um tempo")
def convert_time(**kwargs):
    args = ['hours', 'minutes', 'seconds', 'milliseconds', 'microseconds']
    keys = kwargs.keys()
    values = []
    for arg in args:
        if arg in keys:
            values.append(float(kwargs[arg]))
        else:
            values.append(0)
    return DateHandler.convert_time(values)

@keyword("Eu converto o timer '${timer}'")
def convert_timer(timer):
    return timer.total_seconds()

@keyword("Eu verifico se o timer '${ELAPSED_TIME}' está dentro da tolerância '${TOLERANCE}' de '${TIMER_RUNNING}'")
def check_valid_time(elapsed_time, tolerance, timer_running):
    tolerance_up = timer_running + tolerance
    tolerance_down = timer_running - tolerance
    if convert_timer(elapsed_time - tolerance_down) > 0 and convert_timer(elapsed_time - tolerance_up) < 0:
        return True
    else:
        return False

def get_time(date=None, **kwargs):
    return DateHandler.get_time(date, **kwargs)

@keyword("Eu adquiro a data atual completa em formato compacto")
def perto_get_compact_time():
    return get_time(format="%H%M%S%d%m%Y")

def perto_sleep(seconds):
    return time.sleep(seconds)

def perto_sleep_milliseconds(milliseconds):
    return perto_sleep(milliseconds/1000)
