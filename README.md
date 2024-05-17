
## Configuração do Ambiente

### Configuração do Ambiente Flutter

1. **Configuração do Ambiente Flutter**

    1.1 **Requisitos**
    
    - Certifique-se de que o SDK Flutter esteja instalado e configurado corretamente.
    - Siga as instruções em [Documentação do Flutter](https://docs.flutter.dev/get-started/install/windows/desktop).

    1.2 **Dependências do Flutter**
    
    - Este projeto depende do pacote `http` na versão ^0.13.5.
    - Execute o seguinte comando no seu terminal para obter as dependências:
    
    ```bash
    flutter pub get
    ```

### Configuração do Ambiente Flask

2. **Configuração do Ambiente Flask**

    2.1 **Requisitos**
    
    - Verifique se o Python 3.6 ou superior está instalado no seu sistema.

    2.2 **Instale o Flask**
    
    Flask é um framework leve de aplicativos da web WSGI em Python. Você pode instalá-lo via pip, o instalador de pacotes do Python.
    
    ```bash
    pip install flask
    ```

    2.3 **Ativando o Ambiente Virtual**

    Para gerenciar dependências e isolá-las de outros projetos, é recomendável usar um ambiente virtual. Veja como criar e ativar um ambiente virtual:

    - Para Linux/macOS
    
    ```bash
    $ python3 -m venv .venv
    $ source .venv/bin/activate
    ```

    - Para Windows
    
    ```bash
    > python -m venv .venv
    > .venv\Scripts\activate
    ```

    2.4 **Executando o Servidor Flask**

    Após instalar o Flask e ativar o ambiente virtual, navegue até o diretório `lib/server` no seu terminal e execute o seguinte comando para iniciar o servidor Flask:

    ```bash
    cd lib/server
    flask --app chamar_funcao run
    ```

3. **Executando o Aplicativo Flutter**

    Para executar o aplicativo Flutter, execute o seguinte comando:

    ```bash
    flutter run -d chrome --web-browser-flag "--disable-web-security"
    ```

    Por favor, note que atualmente o aplicativo é executado com a segurança da web desabilitada. Isso pode ser necessário para que certos recursos funcionem corretamente, mas deve ser usado com cautela, especialmente em ambientes de produção.
   
Sinta-se à vontade para entrar em contato se encontrar algum problema ou tiver mais dúvidas. Boa impressão!

