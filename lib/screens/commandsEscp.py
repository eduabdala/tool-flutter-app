import serial
import sys
import argparse
from robot.api.deco import keyword
from robot.api import logger
ser = serial.Serial('COM6', 115200)

@keyword("Eu escrevo o texto ${texto}")
def pipeline_cmd_digitar(texto):
    texto = bytes(texto, encoding='utf8')
    com = b'\x0A'
    ser.write(texto)   
    ser.write(com)
    logger.info(f"Bytes: {com} / {texto}")
    
@keyword("Eu retorno o caracter para o modo normal")
def pipeline_cmd_normal():
    com = bytes('\x1b\x48', encoding='utf-8')
    ser.write(com)

@keyword("Eu habilito o modo sublinhado")
def pipeline_cmd_sublinhado():
    com = b'\x1b\x2D\x01'
    ser.write(com)
    logger.info(f"Comando: {com}")  

@keyword("Eu desabilito o modo sublinhado")
def pipeline_cmd_des_sublinhado():
    com = b'\x1b\x2D\x00'
    ser.write(com)
    logger.info(f"Comando: {com}")  

@keyword("Eu habilito o modo enfatizado")
def pipeline_cmd_enfatizado():
    com = b'\x1b\x45'
    ser.write(com)
    logger.info(f"Comando: {com}")

@keyword("Eu desabilito o modo enfatizado")
def pipeline_cmd_des_enfatizado():
    com = bytes('\x1b\x46', encoding='utf-8')
    ser.write(com)
    logger.info(f"Comando: {com}")

@keyword("Eu habilito o modo italico")
def pipeline_cmd_italico():
    com = bytes('\x1b\x34', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu desabilito o modo italico")
def pipeline_cmd_des_italico():
    com = bytes('\x1b\x35', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu habilito o modo de queima dupla")
def pipeline_cmd_queima_dupla():
    com = b'\x1b\x47'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu desabilito o modo de queima dupla")
def pipeline_cmd_des_queima_dupla():
    com = b'\x1b\x48'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu habilito o modo condensado")
def pipeline_cmd_condensado():
    com = b'\x0F'   
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu desabilito o modo condensado")
def pipeline_cmd_des_condensado():
    com = b'\x12'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu habilito o modo expandido")
def pipeline_cmd_expandido():
    com = bytes('\x1b\x57\x31', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu desabilito o modo expandido")
def pipeline_cmd_des_expandido():
    com = bytes('\x1b\x57\x30', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu habilito o modo sobrescrito")
def pipeline_cmd_sobrescrito():
    com = bytes('\x1b\x53\x00', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu habilito o modo subescrito")
def pipeline_cmd_subescrito():
    com = bytes('\x1b\x53\x01', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu desabilito o modo subescrito")
def pipeline_cmd_des_sobrescrito():
    com = bytes('\x1b\x54', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu seleciono o modo normal")
def pipeline_cmd_modo_normal():
    com = bytes('\x1b\x50', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu imprimo")
def pipeline_cmd_imprimir():
    com = bytes('\x1b\x4A\x34', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}') 

@keyword("Eu aciono a guilhotina")
def pipeline_cmd_guilhotina():
    com = bytes('\x1b\x77', encoding='utf-8')
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu avanço a pagina")
def pipeline_cmd_avanca_pagina():
    com = b'\x0c'
    ser.write(com)
    logger.info(f'Comando: {com}') 

@keyword("Eu avanço uma linha")
def pipeline_cmd_avanca_linha():
    com = b'\x0A'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu tabulo verticalmente")
def pipeline_cmd_tabular_vertical():
    com = b'\x0B'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu retorno o cursor para o início da linha")
def pipeline_cmd_retornar_cursor():
    com = b'\x0D'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu programo o avanço da linha para '${xpto}'")
def pipeline_cmd_avanco_de_linha(xpto):
    cmds = {'1/8':b'\x1b\x30', '7/72':b'\x1b\x31', '1/6':b'\x1b\x32'}
    if xpto in cmds:
        cmd = cmds[xpto]
    return ser.write(cmd)

@keyword("Eu programo o tamanho da pagina em '${xpto}' linhas")
def pipeline_cmd_tamanho_pagina(xpto):
    n = int(xpto)
    com = [0x1b,0x43,n]
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu alinho o texto na '${xpto}'")
def pipeçine_cmd_alinha_texto(xpto):
    mapeamento = {'esquerda': b'\x1b\x61\x30', 'centro':b'\x1b\x61\x31',
                  'direita':b'\x1b\x61\x32'}
    if xpto in mapeamento:
        cmd = mapeamento[xpto]
    return ser.write(cmd)

@keyword("Eu ajusto a margem '${lado}' em '${colunas}' colunas")
def pipeline_cmd_margem(lado,colunas):
    mapLado = {'esquerda':b'\x1b\x6c', 'direita':b'\x1b\x51'}
    colunas = bytes(colunas, encoding='utf-8')
    if lado in mapLado:
        resultado = mapLado[lado]
        cmd = (resultado + colunas)
    return ser.write(cmd)

@keyword("Eu ajusto a margem esquerda em ${colunas} colunas")
def pipeline_cmd_margem_esquerda(colunas):
    n = int(colunas)
    com = bytes([0x1b, 0x6c, n])
    ser.write(com) 
    logger.info(f'Comando: {com}')  
     
@keyword("Eu ajusto a margem direita em ${colunas} colunas")
def pipeline_cmd_margem_direita(colunas):
    n = int(colunas)
    com = bytes([0x1b, 0x51, n])
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu programo o tamanho da pagina em ${linhas} linhas")
def pipeline_cmd_tamanho_pagina(linhas):
    n = int(linhas)
    com = bytes([27, 67, n])
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu seleciono a tabela de caracteres '{caracter}'")
def pipeline_cmd_tabela_caracter(caracter):
    n = int(caracter)
    com = bytes([b'\x1b',b'\x74',n])
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu fecho a porta serial")
def pipeline_cmd_fecha_porta():
    ser.close()

@keyword("Eu inicializo a impressora")
def pipeline_cm_inicializa():
    com = b'\x1b\x40'
    ser.write(com)
    logger.info(f'Comando: {com}')

@keyword("Eu verifico a versão de firmware")
def pipeline_cmd_versao_firmware():
    com = b'\x1b\x75'
    ser.write(com)

@keyword("Eu habilito os atributos '${entrada}'")
def pipeline_cmd_habilitar_bits(entrada):
    # Mapeamento de letras para números (A=0, B=1, ..., H=7)
    mapeamento = {'não_utilizado1':0, 'não_utilizado2': 1, 
                  'condensado': 2, 'enfatizado': 3, 
                  'queima_dupla': 4, 'largura_dupla': 5, 
                  'italico': 6, 'sublinhado': 7}
    # Valor inicial (todos os bits desabilitados)
    resultado = 0b00000000
    # Itera sobre cada letra na entrada
    for letra in entrada.split(','):
        if letra in mapeamento:
            # Encontra o número correspondente à letra
            valor = mapeamento[letra]
            # Habilita o bit correspondente
            resultado |= 1 << valor
    # Retorna o valor com os bits habilitados
    resultado = bytes([0x1b,0x21,resultado])
    return ser.write(resultado)

@keyword("Eu defino o nivel '${xpto}' de correção do qr code")
def cmd_correcao_qr_code(nivel):
    niveis = {'L':b'\x31', 'M':b'\x32', 'Q':b'\x33', 'H':b'\x34'}
    if nivel in niveis:
        nivel = niveis[nivel]
    cmd = b'\x1d\x28\x6b\x03\x00\x31\x45' + nivel
    ser.write(cmd)

@keyword("Eu digito o qr code '${xpto}' com tamanho '${xpto2}'")
def cmd_qr_code(codigo, tamanho):
    codigo = bytes(codigo, encoding='utf-8')
    tamanhoMap = {'minusculo':b'\x01','muito_pequeno':b'\x02',
                  'pequeno':b'\x03','medio':b'\x04', 
                  'grande':b'\x05', 'muito_grande':b'\x06', 'enorme':b'\x07'}
    if tamanho in tamanhoMap:
        valor = tamanhoMap[tamanho]
    cmd = b'\x1d\x28\x6b'
    cmd += (len(codigo) + 3).to_bytes(2, 'little')
    cmd += b'\x31\x50\x30' + codigo
    cmd += b'\x1d\x28\x6b\x03\x00\x31\x43'+ valor
    cmd += b'\x1d\x28\x6b\x03\x00\x31\x51\x30'
    ser.write(cmd)

######## keywords ESCPOS ########

@keyword("Eu habilito a tabulacao horizontal")
def cmd_tab_horizontal():
    ser.write(b'\x09')

@keyword("Eu avanço a linha")
def cmd_avanca_linha_escpos():
    ser.write(b'\x0a')

@keyword("Eu defino o espaçamento entre linhas para 1/6")
def cmd_espacamento_linha():
    cmd = b'\x1b\x32'
    ser.write(cmd)

@keyword("Eu defino o tamanho entre linhas para '${xpto}'")
def cmd_define_espacamento_linhas(xpto):
    xpto = bytes(xpto, encoding='utf-8')
    cmd = b'\x1b\x33'
    cmd += xpto
    ser.write(cmd)

@keyword("Eu seleciono a fonte '${xpto}'")
def cmd_fonte_escpos(xpto):
    opc = {'A':b'\x00', 'B':b'\x01'}
    cmd = b'\x1b\x4d'
    if xpto in opc:
        fonte = opc[xpto]
    cmd += fonte
    ser.write(cmd)

@keyword("Eu imprimo o avanço '${xpto}' linhas")
def cmd_imprime_avanca_linhas(xpto):
    cmd = b'\x1b\x64'
    xpto = bytes(xpto, encoding='utf-8')
    cmd += xpto
    ser.write(cmd)

@keyword("Eu ajusto a altuara do codigo de barras em '${xpto}' pontos")
def cmd_altura_codigo_barras(xpto):
    cmd = b'\x1d\x68'
    xpto = bytes(xpto, encoding='utf-8')
    ser.write(cmd)

@keyword("Eu ajusto o tamanho horizontal do codigo de barras para '${xpto}'")
def cmd_tamanho_hori_cod_barras(xpto):
    xpto = bytes(xpto, encoding='utf-8')
    cmd = b'\x1d\x77'
    ser.write(cmd+xpto)

@keyword("Eu digito '${xpto}' e imprimo o codigo de barras")
def cmd_codigo_barras(xpto):
    xpto = bytes(xpto, encoding='utf-8')
    cmd = (b'\x1d\x6b\x04' + xpto)
    cmd = (cmd + b'\x00')
    ser.write(cmd)
  
@keyword("Eu '${xpto}' o modo enfatizado")
def cmd_enfatizado_escpos(xpto):
    mapeamento = {'habilito': b'\x01', 'desabilito': b'\x00'}
    for status in xpto.split(','):
        if status in mapeamento:
            valor = mapeamento[status]
    cmd = (b'\x1b\x45'+valor)
    return ser.write(cmd)

@keyword("Eu '${xpto}' o modo '${xpto2}'")
def cmd_atributos_escpos(xpto, xpto2):
    mapeamentoStts = {'habilito': b'\x01', 'desabilito': b'\x00'}
    mapeamentoCmd = {'enfatizado': b'\x1b\x45', 'queima_dupla':b'\x1b\x47',
                     'cor_invertida': b'\x1d\x42', 'impressao_invertida':b'\x1b\x7b',
                     'sobrescrito': b'\x1b\x1a\x53', 'subescrito': b'\x1b\x1a\x73'}
    for cmd in xpto2.split(','):
        if cmd in mapeamentoCmd:
            valorCmd = mapeamentoCmd[cmd]
    for status in xpto.split(','):
        if status in mapeamentoStts:
            valorStts = mapeamentoStts[status]
    resultado = bytes(valorCmd+valorStts)
    return ser.write(resultado)

@keyword("Eu seleciono o modo de impressao '${xpto}'")
def cmd_modo_de_impressao(entrada):
    mapeamento = {'fonta_a': 0, 'condensado': 1,
                  'nao_utilizado': 2, 'enfatizado': 3,
                  'altura_dupla': 4, 'largura_dupla': 5,
                  'italico': 6, 'sublinhado': 7}
    resultado = 0b00000000
    for letra in entrada.split(','):
        if letra in mapeamento:
            valor = mapeamento[letra]
            resultado |= 1 << valor
    resultado = bytes([0x1b,0x21,resultado])
    return ser.write(resultado)
   
@keyword("Eu alinho o texto '${xpto}'")
def cmd_alinhamento(entrada):
    mapeamento = {'esquerda':b'\x30','centro':b'\x31','direita':b'\x32'}
    for letra in entrada.split(','):
        if letra in mapeamento:
            valor = mapeamento[letra]
            resultado = (b'\x1b\x61'+valor)
    return ser.write(resultado)

@keyword("Eu '${xpto}' o teclado")
def cmd_teclado(xpto):
    mapeamento = {'desabilito': b'\x00', 'habilito':b'\x01'}
    for letra in xpto.split(','):
        if letra in mapeamento:
            valor = mapeamento[letra]
            resultado = (b'\x1b\x63\x35'+valor)
    return ser.write(resultado)

@keyword("Eu inicializo a impressora escpos")
def cmd_reset():
    cmd = b'\x1b\x40'
    ser.write(cmd)

@keyword("Eu habilito o modo pagina")
def cmd_modo_pagina():
    cmd = b'\x1b\x4c'
    ser.write(cmd)

@keyword("Eu imprimo os dados da pagina e mantenho o modo ativo")
def cmd_imprime_pagina():
    cmd = b'\x1b\x0c'
    ser.write(cmd)

@keyword("Eu immprimo os dados da pagina e volto o modo padrao")
def cmd_modo_padrao():
    cmd = b'\x0c'
    ser.write(cmd)

@keyword("Eu imprimo e avanço '${xpto}' o papel")
def cmd_define_avanco_papel(xpto):
    n = bytes(xpto, encoding='utf-8')
    cmd = b'\x1b\x4a' + n
    ser.write(cmd)


def main(arg1, arg2):
    if len(sys.argv)<2:
        print("forneça o nome da funçao como argumento.")
        return 
    funcao = arg1
    texto = arg2
    if funcao == 'escrever':
        print(pipeline_cmd_digitar(texto))
    elif funcao == 'cortar':
        pipeline_cmd_guilhotina()
        print('ok')
    else:
        print(f"funcao {funcao} nao reconhecida.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Chamar minha funcao com argumentos")
    parser.add_argument("arg1", type=str, help="Primeiro argumento")
    parser.add_argument("arg2", type=str, help="Segundo argumento")
    args = parser.parse_args()
    main(args.arg1, args.arg2)

