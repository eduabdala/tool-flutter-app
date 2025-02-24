
## Configuração do Ambiente

### Configuração do Ambiente Flutter

01. **Configuração do Ambiente Flutter**

    1.1 **Requisitos**
    
    - Certifique-se de que o SDK Flutter esteja instalado e configurado corretamente.
    - Siga as instruções em [Documentação do Flutter](https://docs.flutter.dev/get-started/install/windows/desktop).

    1.2 **Dependências do Flutter**
    - Execute o seguinte comando no seu terminal para obter as dependências:
    
    ```bash
    flutter pub get
    ```

02. **Gerando os arquivos para build**

    Agora, você irá criar o projeto e gerar os arquivos necessários para a construção do aplicativo.

    2.1 **Gerando o projeto Flutter com suporte à plataforma Windows:**

    ```bash
    flutter create --platforms=windows perto_tools
    ```

    - Esse comando cria um projeto Flutter chamado perto_tools com suporte para a plataforma Windows.

    2.2 **Navegando até o diretório do projeto:**

    ```bash
    cd perto_tools
    ```

    2.3 **Verificando se o ambiente está configurado corretamente (garante que o Flutter está pronto para desenvolvimento para Windows):**

    ```bash
    flutter doctor
    ```

    Isso deve confirmar que todas as ferramentas necessárias estão prontas para uso.

    2.4 **Rodando o aplicativo na plataforma Windows:**

    Para executar o app localmente no seu PC com Windows, utilize o comando:

    ```bash
    flutter run -d windows
    ```

    O -d windows garante que o aplicativo será executado em um ambiente de desktop Windows.

    2.5 **Gerando o build para Windows:**

    Quando estiver pronto para gerar a versão compilada do seu aplicativo, use:

    ```bash
    flutter build windows
    ```
    Esse comando cria os arquivos necessários para distribuição do aplicativo no Windows.




