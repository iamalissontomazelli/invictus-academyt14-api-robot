*** Settings ***
Resource    ../../resources/company.resource
Resource        ../../resources/login.resource

*** Test Cases ***
Cadastrar Nova Company Com Sucesso
    Cadastrar Company com Sucesso
    Log    Company criada com ID: ${Company_ID}
    Should Not Be Empty    ${Company_ID}


Listar Todas Companies
    Listar Todas Companies

Buscar Company por ID
    ${id}=    Cadastrar Company com Sucesso
    Buscar Company Por ID    ${id}


