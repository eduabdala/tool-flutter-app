*** Settings ***
Documentation       Robot framework resource to user interaction.
Library           ../libraries/remember.py

*** Keywords ***
Eu configuro uma lista de nomes para os comandos

  # Eu utilizo o nome 'Versao comercial' para o comando 'V'
 #  Eu utilizo o nome 'Versao interna' para o comando 'i'
 #  Eu utilizo o nome 'Versão completa de firmware' para o comando 'ip'
 #  Eu utilizo o nome 'Retorna a data e hora' para o comando ':'
 #  Eu utilizo o nome 'Status de todas as zonas' para o comando 'S'
 #  Eu utilizo o nome 'Aplica a calibração' para o comando 'C'
 #  Eu utilizo o nome 'Limpa flag de proteção contra violação' para o comando '>'
    Eu utilizo o nome 'Retorna a flag de proteção contra violação' para o comando 'F'
 
Eu configuro uma lista de nomes para os parametros
    Eu utilizo o nome 'Zero' para o parametro '0'
    Eu utilizo o nome 'Clean_Flags' para o parametro '0000'
    Eu utilizo o nome 'Violated_Flags' para o parametro '1000'

Eu configuro uma lista de nomes para os atributos
    Eu utilizo o nome 'Zero' para o atributo '0'

Eu configuro uma lista de apelidos
    Eu configuro uma lista de nomes para os comandos
    Eu configuro uma lista de nomes para os parametros
    Eu configuro uma lista de nomes para os atributos
