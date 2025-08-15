*** Settings ***
Documentation        Testes de Cadastro de Cliente (POST) – Funcional e Não Funcional
Resource             ../../resources/client.resource
Suite Setup          Log    Iniciando testes de Client
Suite Teardown       Log    Finalizando testes de Client

*** Test Cases ***

##__Funcional__##
Cadastrar cliente com sucesso
    [Tags]    client    post    funcional    smoke
    Cadastrar Cliente com Sucesso

##__Não Funcional__##
Cliente telefone inválido (não numérico)
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Telefone Inválido

Cliente email inválido
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Email Inválido

# Positivo (já cobre cargo alfabético)
POST - Cadastrar cliente com sucesso
    [Tags]    client    post    funcional    smoke
    Cadastrar Cliente com Sucesso

# Negativo: cargo com números/símbolos
POST - Cliente cargo não alfabético
    [Tags]    client    post    nao_funcional    validacao
    Cliente com Cargo Não Alfabético
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

Cliente duplicado (409)
    [Tags]    client    post    nao_funcional    duplicado
    Cliente Já Cadastrado no Sistema

Remover cliente por id
    [Tags]    client    delete    funcional
    Remover Cliente por Id (Sucesso)






