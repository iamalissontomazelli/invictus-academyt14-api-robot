*** Settings ***
Resource    ../../resources/company.resource
Resource        ../../resources/login.resource

*** Test Cases ***


Atualizar Company Com Sucesso - Teste
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body_create}    Criar Company
    ${resposta_create}    POST On Session    alias=develop    url=/company    json=${body_create}    expected_status=201
    ${company_id}    Set Variable    ${resposta_create.json()["newCompany"]["_id"]}

    # Atualizar a company via PUT usando ID
    ${resposta_put}    Atualizar Company Com Sucesso    ${company_id}

    Should Contain    ${resposta_put["newCompany"]["corporateName"]}    Empresa
    Should Contain    ${resposta_put["newCompany"]["serviceDescription"]}    Servico
