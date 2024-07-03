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
Atualização de firmware 
    [Tags]  firmware-update
    Eu atualizo o firmware
    Eu aguardo '10' segundos
    Eu verifico se a versão comercial de firmware está correta


001 - Teste de versão comercial (Comando 'V')
    [Tags]  auto  smoke  board_only

    Eu verifico se a versão comercial de firmware está correta

 

002 - Leitura de violação (Comando 'S')
    [Tags]  auto  smoke  board_only 

    [Setup]  Run Keywords  Pular teste se o sensor 'Tamper' estiver 'desabilitado'
    ...       AND          Pular teste se o sensor 'Jammer' estiver 'desabilitado'
    ...       AND          Pular teste se o sensor 'Inner' estiver 'desabilitado'

    Eu verifico se o status de violação do sensor 'Tamper' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu verifico se o status de violação do sensor 'Jammer' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

003 - Teste de violação de Tamper
    [Tags]  auto  smoke 

     [Setup]  Run Keywords  Pular teste se o sensor 'Tamper' estiver 'desabilitado'

    Eu verifico se o status de violação do sensor 'Tamper' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu defino o estado do relé '1' para '1'
    Eu defino o estado do relé '1' para '0'
    Eu aguardo '1' segundos
    Eu verifico se o status de violação do sensor 'Tamper' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu limpo o estado de todas as violações e zonas e espero '000'
    Eu aguardo '2' segundos
    Eu defino o estado do relé '1' para '1'
    Eu aguardo '1' segundos
    Eu verifico se o status de violação do sensor 'Tamper' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu limpo o estado de todas as violações e zonas e espero '010'
    Eu defino o estado do relé '1' para '0'
    Eu aguardo '1' segundos
    Eu limpo o estado de todas as violações e zonas e espero '000'
    Eu aguardo '1' segundos
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

004 - Teste de violação do Jammer
    [Tags]  auto  smoke 
     [Setup]  Run Keywords  Pular teste se o sensor 'Jammer' estiver 'desabilitado'

    Eu verifico se o status de violação do sensor 'Jammer' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


005 - Teste de violação do Capacitivo Interno 
    [Tags]  auto  smoke  

     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado'
     ...       AND          Eu seleciono a zona '2' e espero '000'
     ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
     ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'

    Eu defino o estado do relé '9' para '1'
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Suspeita'
    Eu aguardo '12' segundos
    Eu defino o estado do relé '9' para '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu aguardo '17' segundos
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado
    ...         AND           Eu aguardo '1' segundos


006 - Teste de violação do Capacitivo Externo 
    [Tags]  auto  smoke  

     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado'
    ...       AND          Eu seleciono a zona '1' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'

    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu defino o estado do relé '4' para '1'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Suspeita'
    Eu aguardo '12' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu defino o estado do relé '4' para '0'
    Eu aguardo '17' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu defino o estado do relé '2' para '1'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Suspeita'
    Eu aguardo '12' segundos
    Eu defino o estado do relé '2' para '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu aguardo '17' segundos
    Eu verifico que o estado da entrada '4' é '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu defino o estado do relé '6' para '1'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Suspeita'
    Eu aguardo '12' segundos
    Eu defino o estado do relé '6' para '0'
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu aguardo '17' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


007 - Teste de calibração no sensor capacitivo Interno
    [Tags]  auto  smoke

     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado'
    ...       AND          Eu seleciono a zona '2' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'

    Eu defino o estado do relé '9' para '1'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Suspeita'
    Eu realizo a calibração e espero '000'
    Eu aguardo '3' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'
    Eu defino o estado do relé '9' para '0'
    Eu aguardo '3' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Suspeita'
    Eu realizo a calibração e espero '000'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


008 - Teste de calibração no sensor capacitivo Externo
    [Tags]  auto  smoke

     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado'
    ...       AND          Eu seleciono a zona '1' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'
    
    Eu defino o estado do relé '4' para '1'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Suspeita'
    Eu aguardo '15' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu realizo a calibração e espero '000'
    Eu aguardo '2' segundos
    Eu defino o estado do relé '4' para '0'
    Eu aguardo '2' segundos
    Eu realizo a calibração e espero '000'
    Eu aguardo '2' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


009 - Teste de data e hora (Comando 'J')
    [Tags]  auto  smoke  board_only
    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve escrever uma sequência de data e hora válida e inválida.                 |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | ligar a antiskimming enviar o comando e aguradar a sequência terminar.                       |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | O antiskimming deve deve aceitar as datas e horas válidas e rejeitar as inválidas.           |

    Configurar data e hora para '2023-01-01T08:08:00.000' e espero '000'
    Configurar data e hora para '2023-01-01T08:00:60.000' e espero '057'
    Configurar data e hora para '2023-01-01T08:60:00.000' e espero '057'
    Configurar data e hora para '2023-01-01T24:00:00.000' e espero '057'
    Configurar data e hora para '2023-02-28T23:59:59.999' e espero '000'
    Configurar data e hora para '2023-02-29T00:00:00.000' e espero '057'
    Configurar data e hora para '2024-02-29T23:59:59.999' e espero '000'
    Configurar data e hora para '2024-03-01T00:00:00.000' e espero '000'
    Configurar data e hora para '2023-04-31T00:00:00.000' e espero '057'
    Configurar data e hora para '2023-05-01T00:00:00.000' e espero '000'
    Configurar data e hora para '2023-12-31T23:59:59.999' e espero '000'
    Configurar data e hora para '2024-01-01T00:00:10.000' e espero '000'
    Configurar data e hora para '2023-00-01T00:00:00.000' e espero '057'
    Configurar data e hora para '2023-13-01T00:00:00.000' e espero '057'
    Configurar data e hora para '2023-01-00T00:00:00.000' e espero '057'
    Data e hora atuais
    Eu verifico a data e hora

010 - Teste da zona 1 do sensor capacitivo (Comando 'K')
    [Tags]  auto  smoke  board_only

    [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado'
     ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
     ...       AND          Eu seleciono a zona '1' e espero '000'
    
    [Documentation]
    Eu seleciono a zona '1' e espero '000'
    Eu seleciono a zona '3' e espero '057'
    Eu seleciono a zona '4' e espero '057'
    Eu seleciono a zona '5' e espero '057'
    Eu seleciono a zona '6' e espero '057'
    Eu seleciono a zona '7' e espero '057'
    Eu seleciono a zona '8' e espero '057'
    Eu seleciono a zona '9' e espero '057'
    Eu seleciono a zona '10' e espero '057'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

011 - Teste da zona 2 do sensor capacitivo (Comando 'K')
    [Tags]  auto  smoke  board_only

     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado'
     ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
     ...       AND          Eu seleciono a zona '2' e espero '000'

    [Documentation]
    Eu seleciono a zona '2' e espero '000'
    Eu seleciono a zona '3' e espero '057'
    Eu seleciono a zona '4' e espero '057'
    Eu seleciono a zona '5' e espero '057'
    Eu seleciono a zona '6' e espero '057'
    Eu seleciono a zona '7' e espero '057'
    Eu seleciono a zona '8' e espero '057'
    Eu seleciono a zona '9' e espero '057'
    Eu seleciono a zona '10' e espero '057'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

012 - Teste da zona do sensor capacitivo (Comando 'c')
    [Tags]  auto  smoke  board_only
    [Documentation]
    Eu seleciono o sensor 'C' e espero 'C000'
    Eu seleciono o sensor '3' e espero '057'
    Eu seleciono o sensor '4' e espero '057'
    Eu seleciono o sensor '5' e espero '057'
    Eu seleciono o sensor '6' e espero '057'
    Eu seleciono o sensor '7' e espero '057'
    Eu seleciono o sensor '8' e espero '057'
    Eu seleciono o sensor '9' e espero '057'
    Eu seleciono o sensor '10' e espero '057'


013 - Teste da zona do sensor de proximidade (Comando 'c')
    [Tags]  auto  smoke  board_only
    [Documentation]
    Eu seleciono o sensor 'O' e espero '008'
    Eu seleciono o sensor '3' e espero '057'
    Eu seleciono o sensor '4' e espero '057'
    Eu seleciono o sensor '5' e espero '057'
    Eu seleciono o sensor '6' e espero '057'
    Eu seleciono o sensor '7' e espero '057'
    Eu seleciono o sensor '8' e espero '057'
    Eu seleciono o sensor '9' e espero '057'
    Eu seleciono o sensor '10' e espero '057'
    
   
014 - Teste de tempo para detecção de fraude ZONA 1 (Comando 's')
    [Tags]  auto  smoke  board_only  
     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado'
     ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
     ...       AND          Eu seleciono a zona '1' e espero '000'

    [Documentation]
    ...
    ...   | *Objetivo*                                                                                   |
    ...   | O antiskimming deve configurar tempos de detecção de fraude.                                 |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | ligar a antiskimming enviar o comando e aguradar terminar a sequência                        |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | O antiskimming deve aceitar os valores na faixa de min 1 segundo e max 10 minutos.           |
    ...   | Fora dos valores de min e max o antiskimming não deve aceitar.                               |

    Configura o tempo para detecção de fraude 'M10S00' e espero '000'
    Configura o tempo para detecção de fraude 'M10S01' e espero '004'
    Configura o tempo para detecção de fraude 'M05S00' e espero '000'
    Configura o tempo para detecção de fraude 'M10S10' e espero '004'
    Configura o tempo para detecção de fraude 'M11S05' e espero '004'
    Configura o tempo para detecção de fraude 'M12S00' e espero '004'
    Configura o tempo para detecção de fraude 'M14S01' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M10S05' e espero '004'
    Configura o tempo para detecção de fraude 'M11S01' e espero '004'
    Configura o tempo para detecção de fraude 'M11S59' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M14S01' e espero '004'
    Configura o tempo para detecção de fraude 'M15S05' e espero '004'
    Configura o tempo para detecção de fraude 'M16S59' e espero '004'
    Configura o tempo para detecção de fraude 'M20S00' e espero '004'
    Eu aguardo '2' segundos

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

015 - Teste de tempo para detecção de fraude ZONA 2 (Comando 's')
    [Tags]  auto  smoke  board_only 
     
     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado'
     ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
     ...       AND          Eu seleciono a zona '2' e espero '000'

    [Documentation]
   
    Configura o tempo para detecção de fraude 'M10S00' e espero '000'
    Configura o tempo para detecção de fraude 'M10S01' e espero '004'
    Configura o tempo para detecção de fraude 'M05S00' e espero '000'
    Configura o tempo para detecção de fraude 'M10S10' e espero '004'
    Configura o tempo para detecção de fraude 'M11S05' e espero '004'
    Configura o tempo para detecção de fraude 'M12S00' e espero '004'
    Configura o tempo para detecção de fraude 'M14S01' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M10S05' e espero '004'
    Configura o tempo para detecção de fraude 'M11S01' e espero '004'
    Configura o tempo para detecção de fraude 'M11S59' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M13S10' e espero '004'
    Configura o tempo para detecção de fraude 'M14S01' e espero '004'
    Configura o tempo para detecção de fraude 'M15S05' e espero '004'
    Configura o tempo para detecção de fraude 'M16S59' e espero '004'
    Configura o tempo para detecção de fraude 'M20S00' e espero '004'
    Eu aguardo '2' segundos

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado

016 - Teste de tempo de operação da aplicação com zona externa (Comando '+' )
    [Tags]  auto  smoke  board_only 

     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado' 
    ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
    ...       AND          Eu seleciono a zona '1' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'
    
    Eu aguardo '3' segundos
    Eu defino o estado do relé '4' para '1'
    Eu aguardo '1' segundos
    Eu seleciono o tempo de operação '10' e espero '000'
    Eu aguardo '13' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Externo' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu defino o estado do relé '4' para '0'
    Eu aguardo '2' segundos
    Eu seleciono o tempo de operação '1' e espero '000'
    Eu consulto o tempo de operação e espero '50'
    Eu seleciono o tempo de operação '0' e espero '000'
    Eu consulto o tempo de operação e espero '10'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


017 - Teste de tempo de operação da aplicação com zona interna (Comando '+' )
    [Tags]  auto  smoke  board_only 

     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado' 
    ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
    ...       AND          Eu seleciono a zona '2' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'
    
    Eu aguardo '3' segundos
    Eu defino o estado do relé '9' para '1'
    Eu aguardo '1' segundos
    Eu seleciono o tempo de operação '10' e espero '000'
    Eu aguardo '13' segundos
    Eu verifico se o status de violação do sensor 'Capacitivo Interno' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu defino o estado do relé '9' para '0'
    Eu aguardo '2' segundos
    Eu seleciono o tempo de operação '1' e espero '000'
    Eu consulto o tempo de operação e espero '50'
    Eu seleciono o tempo de operação '0' e espero '000'
    Eu consulto o tempo de operação e espero '10'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


018 - Teste de detecção de inserção e de remoção de fraude para os valores padrão de fábrica zona 1 (Comando 'P')
    [Tags]  auto  smoke  board_only 

     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado' 
    ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
    ...       AND          Eu seleciono a zona '1' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'

    Aplica os valores de fábrica para os parâmetros
    Verifica se os tempos de detecção e de normalização são '(M02S15)(M00S15)'
    Eu aguardo '2' segundos

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado
    

019 - Teste de detecção de inserção e de remoção de fraude para os valores padrão de fábrica zona 2 (Comando 'P')
    [Tags]  auto  smoke  board_only

     [Setup]  Run Keywords  Pular teste se o sensor 'Inner' estiver 'desabilitado' 
    ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
    ...       AND          Eu seleciono a zona '2' e espero '000'
    ...       AND          Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    ...       AND          Configura o tempo para normalização de fraude 'M00S10' e espero '000'

    Aplica os valores de fábrica para os parâmetros
    Verifica se os tempos de detecção e de normalização são '(M02S15)(M00S15)'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


020 - Obter data e hora do sistema (comando'J')
    [Tags]  auto  smoke  board_only 

    Data e hora atuais


021 - Teste de resetar a leitora (Comando '_' )
    [Tags]  auto  smoke  board_only 
    [Documentation]
    ...
    ...   | *Objetivo*               OBS: DESLOCAR PARA ULTIMO                                           |
    ...   | O antiskimming deve efetuar a reinicialização                                                |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Ação*                                                                                       |
    ...   | ligar a antiskimming enviar o comando e aguradar a antiskimming estabilizar.                 |
    ...   |                                                                                              |
    ...   |                                                                                              |
    ...   | *Resultado esperado*                                                                         |
    ...   | O antiskimming deve efetuar o reset.                                                          |

    Eu aplico reset na leitora
    Eu aguardo '10' segundos


022 - Teste de estouro na queue 

    [Tags]  auto smoke board_only

     [Setup]  Run Keywords  Pular teste se o sensor 'Outer' estiver 'desabilitado'
     ...       AND          Eu seleciono o sensor 'C' e espero 'C000'
     ...       AND          Eu seleciono a zona '1' e espero '000'

    Eu seleciono o sensor 'C' e espero 'C000'
    Eu seleciono a zona '1' e espero '000'
    Configura o tempo para detecção de fraude 'M10S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M05S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M01S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M00S10' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M01S01' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M02S05' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M03S10' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M04S01' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M05S05' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M06S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    Configura o tempo para detecção de fraude 'M06S05' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M08S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M09S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M10S00' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S01' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S02' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S03' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S04' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S05' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S06' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S07' e espero '000'
    Retorna os tempos de detecção e de normalização
    # Configura o tempo para detecção de fraude 'M00S08' e espero '000'
    Retorna os tempos de detecção e de normalização
    
    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado


023 - 023 - Teste de violação e normalização do jammer
    [Tags]  auto  smoke  board_only 
    
    [Setup]  Run Keywords  Pular teste se o sensor 'Jammer' estiver 'desabilitado'

    Eu defino o estado do relé '3' para '1'
    Eu aguardo '1' segundos
    Eu verifico se o status de violação do sensor 'Jammer' é 'Detectado'
    Eu verifico que o estado da entrada '4' é '1'
    Eu defino o estado do relé '3' para '0'
    Eu aguardo '1' segundos
    Eu verifico se o status de violação do sensor 'Jammer' é 'Ausente'
    Eu verifico que o estado da entrada '4' é '0'

    [Teardown]  Run Keywords  Pular teardown se o teste foi pulado