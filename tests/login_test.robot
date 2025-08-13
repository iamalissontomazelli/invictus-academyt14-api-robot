*** Settings ***
Resource        ../resources/login.resource

*** Test Cases ***
Logar com Sysadmin
    ${token}=    Login com sysadmin
    Log    Token recebido: ${token}

Validar Token Sysadmin    
    ${token}=    Login com sysadmin
    Should Not Be Empty    ${token}
    Set Suite Variable    ${TOKEN}
    Log    Token válido e gravado: ${TOKEN}
