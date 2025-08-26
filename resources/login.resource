*** Settings ***

Library              RequestsLibrary
Library              SeleniumLibrary
Library              String

*** Variables ***

*** Keywords ***
Criar Sessão
    ${headers}=      Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session   alias=develop        url=${baseURL}            headers=${headers}    verify=true

Login com sysadmin
    ${body}=         Create Dictionary
    ...              mail=sysadmin@qacoders.com
    ...              password=1234@Test
    Criar Sessão
    ${resposta}=     POST On Session    alias=develop    url=/login    json=${body}
    Status Should Be    200    ${resposta}
    Set Suite Variable    ${TOKEN}    ${resposta.json()["token"]}
