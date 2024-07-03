*** Settings ***
Documentation       Robot framework resource to user interaction.

Library             BuiltIn
Library             Dialogs
Library             String
Library             Collections
Library             ../libraries/commands.py
Library             ../libraries/datehandler.py

*** Variables ***
${TEST_SKIPPED}=  ${False}

*** Keywords ***
Eu inicializo as variáveis para teste
    ${var}=  Set Variable  Hello World!
    Set Global Variable  ${hello_world}  ${var}

# Eu aguardo '${time}' segundos
#     ${timer}=  Eu converto um tempo  seconds=${time}
#     Aguardar timer '${timer}'

Aguardar timer '${TIMER}'
    ${STORED_TIME}=  Eu armazeno o horário atual
    WHILE  "True"  limit=NONE
        ${CURRENT_TIME}=  Eu armazeno o horário atual
        ${ELAPSED_TIME}=  Eu obtenho a diferença entre os tempos '${CURRENT_TIME}' e '${STORED_TIME}'
        ${TIME_LEFT}=  Eu obtenho a diferença entre os tempos '${TIMER}' e '${ELAPSED_TIME}'
        IF  "${TIME_LEFT}" < "0"
            BREAK
        END
        Sleep  500ms
        # Log To Console  ${\n}Time remaining: ${TIME_LEFT}  no_newline=True
    END
    # Log To Console  ${\n}Elapsed time: ${ELAPSED_TIME}


Pular teste se o sensor '${SENSOR}' estiver '${STATE}'
    ${CHECK_SENSOR}=  Checar se o sensor '${SENSOR}' está '${STATE}'
    IF  ${CHECK_SENSOR} == ${False}
        Set Global Variable  ${TEST_SKIPPED}  ${True}
        Skip  O sensor '${SENSOR}' não está presente
    ELSE
        Set Global Variable  ${TEST_SKIPPED}  ${False}
    END

Passar teste se o sensor '${SENSOR}' estiver '${STATE}'
    ${CHECK_SENSOR}=  Checar se o sensor '${SENSOR}' está '${STATE}'
    IF  ${CHECK_SENSOR} == ${False}
        Pass Execution  O sensor '${SENSOR}' não está presente
    END

Pular teardown se o teste foi pulado
    IF  ${TEST_SKIPPED} == ${True}
        Pass Execution  O teste foi pulado
    END
    
Eu repito a operação '${keyword_to_run}' '${repeats}' vezes
    FOR  ${repeat}  IN RANGE  ${repeats}
        Run Keyword  ${keyword_to_run}
    END