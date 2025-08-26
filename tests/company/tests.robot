*** Settings ***
Documentation     Suite única para testes de Company (GET, POST, PUT)
Resource          ../../resources/company.resource
Resource          ../../resources/login.resource
Library           Collections
Library           String
Library           RequestsLibrary

*** Variables ***
${COMPANY_ID}    NONE

*** Test Cases ***

# ======================================================
# GET - Listagem e Consulta
# ======================================================
GET - Listar Todas Companies
    [Tags]    get    company    smoke    positive
    Listar Todas Companies

GET - Buscar Company por ID
    [Tags]    get    company    regression    positive
    ${id}=    Cadastrar Company com Sucesso
    Buscar Company Por ID    ${id}

GET - Testar Contagem de Companies
    [Tags]    get    company    regression    positive
    ${resultado}=    Contar Companies
    Should Be True    ${resultado['count']} >= 0    msg=Contagem inválida

# ======================================================
# POST - Criação de Companies
# ======================================================
POST - Cadastrar Nova Company Com Sucesso
    [Tags]    post    company    regression    positive
    ${resposta}    Cadastrar Company com Sucesso
    Should Contain    ${resposta["msg"]}    foi cadastrada com sucesso

POST - Cadastrar Company Sem Nome
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Sem Nome
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Nome da empresa' é obrigatório.

POST - Cadastrar Company Nome Maior Que 100 Caracteres
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Nome Maior Que 100 Caracteres
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Nome da empresa' deve ter no máximo 100 caracteres.

POST - Cadastrar Nova Company Nome Alfanumerico
    [Tags]    post    company    regression    positive
    ${msg}=    Cadastrar Company Nome Alfanumerico
    Should Contain    ${msg}    foi cadastrada com sucesso

POST - Cadastrar Company Nome Duplicado
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Nome Duplicado
    Should Be Equal As Strings    ${resposta["alert"][0]}    Uma companhia com este nome já está cadastrada. Por favor, escolha outro nome.

POST - Cadastrar Company Sem CNPJ
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Sem CNPJ
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa é obrigatório.

POST - Cadastrar Company CNPJ Nao Numerico
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company CNPJ Nao Numerico
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa deve conter apenas números.

POST - Cadastrar Company CNPJ Duplicado
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company CNPJ Duplicado
    Should Be Equal As Strings    ${resposta["alert"][0]}    Essa companhia já está cadastrada. Verifique o nome, CNPJ e a razão social da companhia.

POST - Cadastrar Company CNPJ Maior Que 14 Digitos
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company CNPJ Maior Que 14 Digitos
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa deve ter no máximo 14 caracteres numéricos.

POST - Cadastrar Company Sem Matriz
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Sem Matriz
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Razão Social' é obrigatório.

POST - Cadastrar Nova Company Matriz Alfanumerica
    [Tags]    post    company    regression    positive
    ${msg}=    Cadastrar Company Matriz Alfanumerica
    Should Contain    ${msg}    foi cadastrada com sucesso

POST - Cadastrar Company Matriz Duplicada
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Matriz Duplicada
    Should Be Equal As Strings    ${resposta["alert"][0]}    Essa companhia já está cadastrada. Verifique o nome, CNPJ e a razão social da companhia.

POST - Cadastrar Company Matriz Maior Que 100 Caracteres
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Matriz Maior Que 100 Caracteres
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Razão Social' da empresa deve ter no máximo 100 caracteres.

POST - adastrar Company Sem Contato Responsavel
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Sem Contato Responsavel
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contado do Responsável' é obrigatório.

POST - Contato Responsavel Somente Letras
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Contato Responsavel Somente Letras
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contato do Responsável' deve ter nome e sobrenome, contendo somente letras.

POST - ontato Responsavel Maximo 100
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Contato Responsavel Maximo 100
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contado do Responsável' deve ter no máximo 100 caracteres.

POST - ontato Responsavel Minimo Duas Palavras
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Contato Responsavel Minimo Duas Palavras
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contato do Responsável' deve ter nome e sobrenome, contendo somente letras.

POST - Telefone Obrigatorio
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Telefone Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Telefone' é obrigatório.

POST - Telefone Somente Numeros
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Telefone Somente Numeros
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo telefone deve conter um número válido do Brasil.

POST - Telefone Maximo 
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Telefone Maximo
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo telefone deve conter um número válido do Brasil.

POST - Email Obrigatorio
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Email Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Email' é obrigatório.

POST - Email Formato Invalido
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company Email Formato Invalido
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Email' informado é inválido. Informe um e-mail no formato [nome@domínio.com].

POST - ServiceDescription Obrigatorio
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company ServiceDescription Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Descrição' é obrigatório.

POST - ServiceDescription Nao Alfanumerico
    [Tags]    post    company    regression    negative    validation
    ${resposta}=    Cadastrar Company ServiceDescription Invalida    Loja de *Doces@2025
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Descrição' só pode conter letras e os caracteres especiais permitidos

POST - Cadastrar Company Sem Logradouro
    [Tags]    post    company    regression    negative    validation
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    Remove From Dictionary    ${body["address"][0]}    street
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'logradouro' é obrigatório.

POST - Cadastrar Company Logradouro Com Caracteres Inválidos
    [Tags]    post    company    regression    negative    validation
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    Set To Dictionary    ${body["address"][0]}    street    @@@###   # caracteres inválidos
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'logradouro' só pode conter letras, números e os caracteres especiais 'ª', 'º', '‘' e '-'

POST - Cadastrar Company Logradouro Com Caracteres Especiais Permitidos
    [Tags]    post    company    regression    positive
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    Set To Dictionary    ${body["address"][0]}    street    Rua 1ª Travessa-Centro
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Log    ${resposta.json()}

POST - Cadastrar Company Logradouro Acima De 50 Caracteres
    [Tags]    post    company    regression    negative    validation
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    ${logradouro_invalido}=    Evaluate    "A" * 51
    Set To Dictionary    ${body["address"][0]}    street    ${logradouro_invalido}
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'logradouro' deve possuir no máximo 50 caracteres.

# ======================================================
# PUT - Atualização de Companies
# ======================================================
PUT - Criar Company Para Testes
    [Tags]    put    company    regression    setup
    ${TOKEN}=       Login com sysadmin
    ${headers}=     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session  develop    ${baseURL}    headers=${headers}    verify=true
    ${body_create}=    Criar Company
    ${resposta_create}=    POST On Session    develop    /company    json=${body_create}    expected_status=201
    Log To Console    ${resposta_create.json()}
    ${resposta_list}=    GET On Session    develop    /company    expected_status=200
    ${lista}=    Set Variable    ${resposta_list.json()}
    ${ultimo}=   Get From List    ${lista}    -1
    ${company_id}=    Set Variable    ${ultimo["_id"]}
    Log To Console    Company criada com id: ${company_id}
    Set Suite Variable    ${COMPANY_ID}    ${company_id}

PUT - Atualizar Company com Sucesso
    [Tags]    put    company    regression    positive
    ${resposta}=    Atualizar Company Com Sucesso    ${COMPANY_ID}
    Dictionary Should Contain Key    ${resposta}    _id
    Dictionary Should Not Contain Key    ${resposta}    error


PUT - Atualizar Company com Nome Vazio
    ${resposta}=    Atualizar Company Nome Vazio    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com CNPJ Inválido
    ${resposta}=    Atualizar Company CNPJ Invalido    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com Razão Social Vazia
    ${resposta}=    Atualizar Company Razao Social Vazia    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com Contato Inválido
    ${resposta}=    Atualizar Company Contato Invalido    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com Telefone Inválido
    ${resposta}=    Atualizar Company Telefone Invalido    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com Email Inválido
    ${resposta}=    Atualizar Company Email Invalido    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error

PUT - Atualizar Company com Descrição Vazia
    ${resposta}=    Atualizar Company Descricao Vazia    ${COMPANY_ID}
    Log To Console    ${resposta}
    Dictionary Should Contain Key    ${resposta}    error


