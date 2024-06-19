from robot.api.deco import keyword
from encoder import encoder

remember_table = dict()

def remember_table_set(remember_name, dicionary, remember_value):
    global remember_table
    if not dicionary in remember_table:
        remember_table[dicionary] = dict()
    remember_table[dicionary][remember_name] = encoder(remember_value)

def remember_table_set_no_encoding(remember_name, dicionary, remember_value):
    global remember_table
    if not dicionary in remember_table:
        remember_table[dicionary] = dict()
    remember_table[dicionary][remember_name] = remember_value

def remember_table_get(remember_name, dicionary):
    global remember_table
    if dicionary in remember_table and remember_name in remember_table[dicionary]:
        remember_name = remember_table[dicionary][remember_name]
    return remember_name

def remember_table_all(dicionary):
    global remember_table
    return remember_table[dicionary] if dicionary in remember_table else dict()

@keyword("Eu utilizo o nome '${remember_name}' para o comando '${remember_value}'")
def remember_table_set_command(remember_name, remember_value):
    remember_value = encoder(remember_value)
    remember_table_set(remember_name, 'comando', remember_value)

@keyword("Eu utilizo o nome '${remember_name}' para o parametro '${remember_value}'")
def remember_table_set_param(remember_name, remember_value):
    remember_table_set(remember_name, 'parametro', remember_value)

@keyword("Eu utilizo o nome '${remember_name}' para o atributo '${remember_value}'")
def remember_table_set_attribute(remember_name, remember_value):
    remember_table_set(remember_name, 'atributo', remember_value)
