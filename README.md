
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
    flutter create --platforms=windows flutter_tools
    ```

    - Esse comando cria um projeto Flutter chamado flutter_tools com suporte para a plataforma Windows.

    2.2 **Navegando até o diretório do projeto:**

    ```bash
    cd flutter_tools
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

## Capturas de Tela

Abaixo estão algumas imagens demonstrando o funcionamento do aplicativo:

<p align="center">
  <img src="assets/screenshots/Screenshot-menu-dark.png" alt="Tela inicial do app" width="600"/>
</p>
<p>imagem 1: Tela inicial do app.</p>

<p align="center">
  <img src="assets/screenshots/Screenshot-data-chart.png" alt="Outra funcionalidade do app" width="600"/>
</p>
<p>imagem 2: Tela de comunicação serial.</p>

<p align="center">
  <img src="assets/screenshots/Screenshot-key-derivation.png" alt="Outra funcionalidade do app" width="600"/>
</p>
<p>imagem 3: Tela de derivação de chave.</p>


<p align="center">
  <img src="assets/screenshots/Screenshot-menu-light.png" alt="Tela inicial do app claro" width="600"/>
</p>
<p>imagem 4: Tela mostrando modo claro do app e sistema de abas.</p>

