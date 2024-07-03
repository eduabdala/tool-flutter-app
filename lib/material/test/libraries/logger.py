from robot.api import logger

def log_info(msg):
    logger.info(msg, html=True)
    log_console(msg)
    return msg

def log_error(msg):
    logger.error(msg, html=True)

def log_console(msg):
    logger.console(msg)
