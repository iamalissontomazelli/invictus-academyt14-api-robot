*** Settings ***
Documentation        Testes de Cadastro de Cliente (POST) – Funcional e Não Funcional
Resource             ../../resources/client.resource
Suite Setup          Log    Iniciando testes de Client
Suite Teardown       Log    Finalizando testes de Client

*** Test Cases ***

# ---------------- GET (listar/buscar) ----------------------
GET - Listar clientes (200) e exibir primeiros itens
    [Tags]    client    get    lista    positivo
    ${lista}=    Listar Clientes (GET)
    Should Not Be Empty    ${lista}

GET - Cliente id válido existente (200)
    [Tags]    client    get    id    positivo
    Cliente Id Válido Deve Retornar 200

# ---------------- Metodo POST ( Cadastro de cliente ) ----------------------
## 25163 - CADASTRAR CLIENTE COM SUCESSO
Cadastrar cliente com sucesso
    [Tags]    client    post    funcional    smoke
    Cadastrar Cliente com Sucesso

Cliente duplicado (409)
    [Tags]    client    post    nao_funcional    duplicado
    Cliente Já Cadastrado no Sistema

#
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

Cliente campos obrigatórios vazios
    [Tags]    client    post    nao_funcional    validacao
    Cliente campos Obrigatórios Vazios

# 25310 - RAMO DE ATIVIDADE (somente alfabético)

POST - Ramo de atividade somente texto alfabético (sucesso)
    [Tags]    client    post    funcional    ramo
    [Template]    Ramo Alfabético Deve Aprovar
    Tecnologia da Informação
    Comércio Varejista
    Serviços Gerais
    Indústria Metalúrgica
    Educação Básica

# ---------------- Metodo PUT (Atualizar/Editar Dados de Cliente) --------------------------
# 25369 - Editar Cadastro de cliente

PUT - Atualizar cliente com sucesso
    [Tags]    client    put    funcional
    Atualizar Cliente por Id (Sucesso)

Atualizar Cliente com Body Inválido
    [Tags]    client    put    negativo
    Atualizar Cliente com Body Inválido (400)

PUT - Atualizar cliente inexistente (404/400)
    [Tags]    client    put    negativo
    Atualizar Cliente Inexistente (404/400)

# ---------------- DELETE --------------------------
Remover cliente por id
    [Tags]    client    delete    funcional
    Remover Cliente por Id (Sucesso)








