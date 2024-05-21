import os
import sys
import serial

ser = serial.Serial('COM6', 115200)

def funcao1():
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
    texto = bytes(texto, encoding='utf8')
    ser.write(texto)

def guilhotina():
    ser.write(b'\x1b\x77')

def main():
    if len(sys.argv)<2:
        print("forneça o nome da funçao como argumento.")
        return 
    funcao = sys.argv[1]
    if funcao == 'funcao1':
        print(funcao1())
    elif funcao == 'funcao2':
        guilhotina()
        print('ok')
    else:
        print(f"funcao {funcao} nao reconhecida.")

if __name__ == "__main__":
    main()
