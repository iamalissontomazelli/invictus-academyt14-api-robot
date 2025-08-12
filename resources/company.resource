*** Settings ***
Documentation        Recursos para testar API Company
Library    RequestsLibrary
Library    SeleniumLibrary
Library    String
Library    Collections
Resource    login.resource

*** Keywords ***

Criar Company
    # Gerar nome e sobrenome só com letras minúsculas
    ${nome1_raw}    Generate Random String    length=6    chars=[LOWER]
    ${nome1}        Convert To Title Case    ${nome1_raw}

    ${nome2_raw}    Generate Random String    length=8    chars=[LOWER]
    ${nome2}        Convert To Title Case    ${nome2_raw}

    ${responsavel}  Set Variable             ${nome1} ${nome2}

    # Validar formato do responsável para evitar erro na API
    Should Match Regexp    ${responsavel}    ^[A-Z][a-z]+ [A-Z][a-z]+$

    # Telefone aleatório
    ${telefone_aleatorio}  Generate Random String    length=9    chars=[NUMBERS]
    ${telefone_random}     Set Variable             5511${telefone_aleatorio}

    # Número e endereço randomizado
    ${numero_random}       Evaluate    random.randint(1, 9999)    modules=random
    ${cep_random}          Evaluate    random.choice(["04777001", "01001000", "12345678"])    modules=random
    ${cidade_random}       Evaluate    random.choice(["São Paulo", "Rio de Janeiro", "Curitiba"])    modules=random
    ${estado_random}       Evaluate    random.choice(["SP", "RJ", "PR"])    modules=random
    ${bairro_random_raw}   Generate Random String    length=8    chars=[LOWER]
    ${bairro_random}       Convert To Title Case    ${bairro_random_raw}
    ${rua_random_raw}      Generate Random String    length=12   chars=[LOWER]
    ${rua_random}          Convert To Title Case    ${rua_random_raw}
    ${complemento_numero}  Evaluate    random.randint(1, 500)    modules=random
    ${complemento_random}  Set Variable             Apt ${complemento_numero}

    # Criar corpo do request
    ${body}    Create Dictionary
    ...    corporateName=Empresa ${nome1}
    ...    registerCompany=12345678000199
    ...    mail=test${nome1.lower()}@teste.com
    ...    matriz=Matriz ${nome1}
    ...    responsibleContact=${responsavel}
    ...    telephone=${telefone_random}
    ...    serviceDescription=Serviço de ${nome1}
    ...    address=@{EMPTY}

    ${endereco}    Create Dictionary
    ...    zipCode=${cep_random}
    ...    city=${cidade_random}
    ...    state=${estado_random}
    ...    district=${bairro_random}
    ...    street=${rua_random}
    ...    number=${numero_random}
    ...    complement=${complemento_random}
    ...    country=Brasil

    Append To List    ${body["address"]}    ${endereco}

    RETURN    ${body}



Cadastrar Company com Sucesso
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Set Suite Variable    ${Company_ID}    ${resposta.json()["newCompany"]["_id"]}
    RETURN    ${Company_ID}

Listar Todas Companies
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Buscar Company Por ID
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company/${company_id}    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Contar Companies
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company/count    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}



