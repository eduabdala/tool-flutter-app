**Revisar item**

Toda revisão de 206, deve revisar a respectiva ETE

- [ ] Gerar release no GitLab
- [ ] Criar FAE
- [ ] Criar revisão do 206
- [ ] Criar revisão da ETE
- [ ] Criar RT de teste na pasta *Documentos Gerais* do CS do 206

----
Na FAE:
- [ ] Revisão do 206 está presente
- [ ] Revisão da ETE está presente
- [ ] Problema: Descrever o problema que a alteração liberada pela FAE resolve
- [ ] Validação: Como foi validada a alteração
- [ ] Afeta produto em campo: Se afeta, tem que ter BT.
- [ ] BT: Se não tem BT mecânico ou de HW, Pode usar o BT0909 para indicar como atualizar o FW
- [ ] Disposição: **Verificar com supervisão** o tratamento da atualização!!!

----
Preencher aba Controle de Software do 206
- [ ] Versão comercial (verificar incremento)
- [ ] Versão fábrica (verificar incremento)
- [ ] Local na rede
- [ ] Etiqueta (Versão e hash)
- [ ] Release
- [ ] Alterações
- [ ] Observações
    - Informações de uso
    - Comando detalhado de versão (fábrica, release, etc)
- [ ] Copiar binários para pasta Montagem
- [ ] Preencher Hash, Tipo de Hash e Observações no quadro de *Objetos*
- [ ] Verificar se possui versão de homologação

----
Relatório de testes
- [ ] Adicionar os artefatos ao RT

----
ETE
- [ ] Está na pasta *Documentos Gerais* do 206
- [ ] Revisão do cabeçalho é a mesma do quadro de revisão histórica
- [ ] Histórico de revisão tem a FAE
- [ ] Versão de firmware da ETE está de acordo com aba Controle de Software do 206

----
Se tem CS antigo, então:
- [ ] Remover CS da pasta *Documentos Gerais*

----
- [ ] Encaminhar FAE para aprovação

----
Publicação de binários
- [ ] Liberado: Criar diretório da versão (Não mover)
- [ ] Liberado: Copiar binários da pasta *deploy* para diretório criado
- [ ] Fonte_Oficiais: Criar diretório da versão (Não mover)
- [ ] Fonte_Oficiais: Copiar binários da pasta *deploy* para diretório criado
- [ ] Fonte_Oficiais: Copiar fontes

----
Após aprovado:
- [ ] **Se tem CS antigo**, obsoletar CS antigo após aprovação da revisão do 206;
- [ ] Copiar os arquivos antigos do *Liberado* para o Fonte_Oficiais
- [ ] Deletar os arquivos antigos do *Liberado* 
