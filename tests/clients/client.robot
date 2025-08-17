*** Settings ***
Documentation        Testes de Cadastro de Cliente (POST) – Funcional e Não Funcional
Resource             ../../resources/client.resource
Suite Setup          Log    Iniciando testes de Client
Suite Teardown       Log    Finalizando testes de Client

*** Test Cases ***

# ---------------- GET (listar/buscar) ----------------------





# ---------------- Metodo POST ( Cadastro de cliente ) ----------------------
## 25163 - CADASTRAR CLIENTE COM SUCESSO
Cadastrar cliente com sucesso
    [Tags]    client    post    funcional    smoke
    Cadastrar Cliente com Sucesso

Cliente duplicado (409)
    [Tags]    client    post    nao_funcional    duplicado
    Cliente Já Cadastrado no Sistema

# Negativo: cargo com números/símbolos
POST - Cliente cargo não alfabético
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Cargo Não Alfabético

##__Não Funcional__##
Cliente telefone inválido (não numérico)
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Telefone Inválido

Cliente email inválido
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Email Inválido

# 25307 - CARGO SOMENTE TEXTO ALFABÉTICO

POST - Cargo somente texto alfabético (sucesso)
    [Tags]    client    post    funcional    cargo
    Cargo com Valor Alfabético Deve Aprovar

POST - Cargo com números ou símbolos (erro)
    [Tags]    client    post    nao_funcional    cargo
    Cargo com Valor Não Alfabético Deve Reprovar

Cliente ramo não alfabético
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Ramo Não Alfabético

Cliente temperatura inválida
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Temperatura Inválida

Cliente comissão inválida
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Comissão Inválida

Cliente campos obrigatórios vazios
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Campos Obrigatórios Vazios


# 25310 - RAMO DE ATIVIDADE (somente alfabético)

POST - Ramo de atividade somente texto alfabético (sucesso)
    [Tags]    client    post    funcional    ramo
    [Template]    Ramo Alfabético Deve Aprovar
    Tecnologia da Informação
    Comércio Varejista
    Serviços Gerais
    Indústria Metalúrgica
    Educação Básica



# ---------------- Metodo PUT (atualizar) --------------------------











Remover cliente por id
    [Tags]    client    delete    funcional
    Remover Cliente por Id (Sucesso)








