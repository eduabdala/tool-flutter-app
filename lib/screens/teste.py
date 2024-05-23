import os
import sys
import argparse
import serial

ser = serial.Serial('COM6', 115200)

def funcaoTeste():
    caminho_pasta = os.path.dirname(__file__)
    nome_arquivo = "arquivoTeste.txt"
    conteudo = "funcionando"
    
    try:
        if not os.path.exists(caminho_pasta):
            os.makedirs(caminho_pasta)
        caminho_arquivo = os.path.join(caminho_pasta, nome_arquivo)
        with open(caminho_arquivo, 'w') as arquivo:
            arquivo.write(conteudo)
        print(f"Arquivo '{nome_arquivo}' criado em '{caminho_pasta}' com sucesso!")
    except Exception as e:
        print(f"Erro ao criar o arquivo: {e}")

def escrever(texto):
    print(texto)
    texto = bytes(texto, encoding='utf8')
    ser.write(texto)

def guilhotina():
    ser.write(b'\x1b\x77')

def main(arg1, arg2):
    if len(sys.argv)<2:
        print("forneça o nome da funçao como argumento.")
        return 
    funcao = arg1
    texto = arg2
    if funcao == 'funcao1':
        print(escrever(texto))
    elif funcao == 'funcao2':
        guilhotina() 
        print('ok')
    else:
        print(f"funcao {funcao} nao reconhecida.")

def teste(texto):
    print(texto)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Chamar minha funcao com argumentos")
    parser.add_argument("arg1", type=str, help="Primeiro argumento")
    parser.add_argument("arg2", type=str, help="Segundo argumento")
    args = parser.parse_args()
    main(args.arg1, args.arg2)
