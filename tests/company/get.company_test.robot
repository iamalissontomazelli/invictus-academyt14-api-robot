*** Settings ***
Resource    ../../resources/company.resource
Resource        ../../resources/login.resource

*** Test Cases ***


Listar Todas Companies
    Listar Todas Companies

Buscar Company por ID
    ${id}=    Cadastrar Company com Sucesso
    Buscar Company Por ID    ${id}

Testar Contagem de Companies
    ${resultado}=    Contar Companies
    Should Be True    ${resultado['count']} >= 0    msg=Contagem inválida