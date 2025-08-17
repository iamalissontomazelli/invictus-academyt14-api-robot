*** Settings ***
Documentation        Testes de Cadastro de Cliente (POST) – Funcional e Não Funcional
Resource             ../../resources/client.resource
Suite Setup          Log    Iniciando testes de Client
Suite Teardown       Log    Finalizando testes de Client

*** Test Cases ***

# ---------------- GET (listar/buscar) ----------------------

# ====== VALIDAÇÃO DE CLIENT ID ======
GET - Cliente id válido existente (200)
    [Tags]    client    get    id    positivo
    Cliente Id Válido Deve Retornar 200

GET - Cliente id malformado (400)
    [Tags]    client    get    id    negativo
    Cliente Id Malformado Deve Reprovar

GET - Cliente id válido porém inexistente (404)
    [Tags]    client    get    id    negativo
    Cliente Id Válido Porem Inexistente Deve Reprovar

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

# ---------------- Metodo PUT (Atualizar/Editar Dados de Cliente) --------------------------


# 25369 - Editar Cadastro de cliente

PUT - Atualizar cliente com sucesso
    [Tags]    client    put    funcional
    Atualizar Cliente por Id (Sucesso)

PUT - Atualizar cliente com body inválido (400/422)
    [Tags]    client    put    negativo
    Atualizar Cliente com Body Inválido (400)

PUT - Atualizar cliente com id malformado (400)
    [Tags]    client    put    negativo
    Atualizar Cliente com Id Malformado (400)

PUT - Atualizar cliente inexistente (404)
    [Tags]    client    put    negativo
    Atualizar Cliente Inexistente (404)












Remover cliente por id
    [Tags]    client    delete    funcional
    Remover Cliente por Id (Sucesso)








