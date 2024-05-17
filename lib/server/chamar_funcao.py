from flask import Flask, request
import teste
import serial

app = Flask(__name__)

@app.route('/chamar_funcao', methods=['POST','GET'])
def chamar_funcao():
    data = request.form
    funcao = data.get('funcao')
    
    if funcao == 'funcao':
        resultado = teste.funcao()
    elif funcao == 'funcao2':
        resultado = cortar()
    else:
        resultado = 'Função não encontrada'

    return resultado

def funcao1():
    return('funcao 1')

def cortar():
    print('\x1b\x77')

if __name__ == '__main__':
    app.run(debug=True)
