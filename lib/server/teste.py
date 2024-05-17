import os

def funcao():
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

funcao()