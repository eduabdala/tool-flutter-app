*** Settings ***
Documentation     General Antiskimming SU Test Suite
...
...               This test has a workflow that is created using keywords in
...               the imported resource file.

Resource          ../resources/list.resource
Resource          ../resources/commands.resource

Suite Setup      Run Keywords
...              Eu configuro uma lista de apelidos
...              Eu inicializo as variáveis para teste
...              Eu configuro a porta serial
...              Eu configuro o log da serial

*** Test Cases ***

001 - Consulta de versão comercial do firmware
    [Tags]  auto smoke  
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar a versão comercial do firmware.                                  |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado a versão comercial do firmware ao antiskimming e realizada uma                   |
    ...   | verificação de versão.                                                                       |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar a versão comercial do firmware, sem apresentar erros no comando.               |

    Eu verifico se a versão comercial de firmware está correta
    

002 - Consulta de versão completa de firmware
    [Tags]  auto  smoke  board_only
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar a versão completa do firmware como resposta do comando (ip),    |
    ...   | sendo: i<{fw_commercial}><{fw_internal}><{SVN Review}>                                       |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado a versão completa do firmware ao dispositivo e realizada uma                    |
    ...   | verificação de versão.                                                                       |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar a versão completa do firmware, sem apresentar erros no comando.                |

    Eu verifico a versão completa de firmware


003 - Consulta da revisão do GIT 
    [Tags]  auto  smoke  board_only
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar a versão do GIT.                                                |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado a data e hora.                                                                  |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar a data e hora configurada no antiskimming.                                      |

    Eu verifico a versão de repositório

004 - Retorna data e hora
    [Tags]  auto  smoke  board_only  

     [Setup]  Run Keywords  Eu repito a operação 'Eu verifico a data e hora' '2' vezes
     
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar a data e hora.                                                  |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado a data e hora.                                                                  |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar a data e hora configurada no antiskimming.                                      |

    Eu verifico a data e hora


005 - Calibração no sensor capacitivo
    [Tags]  auto  smoke  board_only 
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O scanner deve realizar a operção de habilita e desabilita escaneamento.                     |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | Porta do shutter abre ao habilitar escaneamento e fecha ao desabilitar o escaneamento.       |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Comandos Habilita Escaneamento (E) e Desabilita Escanemaneto (D), são executados com         |
    ...   | sucesso, sem apresentar falhas.                                                              |

    Eu realizo a calibração e espero '000'


006 - Retorna a flag de proteção contra violação  
    [Tags]  auto  smoke  board_only 
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve lê a flag das proteções contra violação                                   |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | Primeiro enviar o comando e ler as flags, depois violar o antiskimming e observar a mudança   |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | O antiskmming na primeira leitura deve retornar "0000". Depois de violado deve retornar      |
    ...   | "1000"                                                                                       |

    Eu verifico se a flag de proteção contra violação está 'inativa'


007 - Retorna o estado de de todas as violações e zonas
    [Tags]  auto  smoke  board_only 

    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar o estado de todas as violações e zonas do dispositivo..         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado o status de todas as violações e zonas.                                         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar os status de violação e zona do antiskimming.                                   |

    Eu limpo o estado de todas as violações e zonas e espero '000'

    
008 - Retorna a quantidade total de eventos disponivel no antiskimming
    [Tags]  auto  smoke  board_only   
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar o estado de todas as violações e zonas do dispositivo..         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado o status de todas as violações e zonas.                                         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar os status de violação e zona do antiskimming.                                   |

    Retorna a quantidade total de eventos


009 - Retorna o estado atual do sensor do sistema Antiskimming
    [Tags]  auto  smoke  board_only  
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar o estado de todas as violações e zonas do dispositivo..         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado o status de todas as violações e zonas.                                         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar os status de violação e zona do antiskimming.                                   |

    Retorna o estado atual do sensor do sistema Antiskimming


010 - Retorna os tempos de detecção e de normalização do antiskimming
    [Tags]  auto  smoke  board_only  
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve retornar o estado de todas as violações e zonas do dispositivo..         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | É solicitado o status de todas as violações e zonas.                                         |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | Deve retornar os status de violação e zona do antiskimming.                                   |

    Retorna os tempos de detecção e de normalização
    

011 - Aplica os valores de fábrica para os parâmetros (Comando 'P')
    [Tags]  auto  smoke  board_only 

    Aplica os valores de fábrica para os parâmetros


