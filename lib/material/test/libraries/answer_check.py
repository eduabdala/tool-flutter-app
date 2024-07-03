import itertools
import re
import logger
import datehandler

def find_regex(expression, answer):
    search = re.findall(expression, answer)
    search = ''.join(tuple(itertools.chain(*search)))
    if not search:
        raise Exception(f"Procurando por /{expression}/ mas recebido '{answer}'")
    return search

def expect_answer(expected, answer):
    if expected != answer:
        raise Exception(f"Esperado '{expected}' mas recebido '{answer}'")
    logger.log_info(f"Resposta recebida: {answer}")
    return [expected, answer]

def exec_command_with_timeout(command, timeout):
    timeout = datehandler.get_time_plus(datehandler.store_time(), datehandler.convert_time(seconds=timeout))
    while timeout > datehandler.store_time():
        try:
            answer = command()
        except Exception as error:
            if timeout < datehandler.store_time():
                raise error
        else:
            break
    return answer

def exec_command_with_repeats(command, repeats):
    for repeat in range(repeats):
        try:
            answer = command()
        except Exception as error:
            if repeat == repeats-1:
                raise error
        else:
            break
    return answer
