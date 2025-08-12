*** Settings ***
Documentation        Arquivo das Bibliotecas

Library        RequestsLibrary
Library        SeleniumLibrary
Library        String
Resource       user.resource




*** Variables ***
${baseURL}         https://api-supernatural.qacoders.dev.br/api/



*** Keywords ***
Criar Sessão
    ${headers}         Create Dictionary        accept=application/json       Content-Type=application/json 
    Create Session    alias=develop    url=${baseURL}       headers=${headers}        verify=true

Login com sysadmin    
    ${body}         Create Dictionary       
    ...    mail=sysadmin@qacoders.com        
    ...    password=1234@Test  
     
    Criar Sessão  
    ${resposta}     POST On Session        alias=develop         url=/Login        json=${body}
    Log To Console            RESPOSTA JSON: ${resposta.json()}
    Log To Console            O TOKEN É: ${resposta.json()["token"]}    
    Status Should Be          200    ${resposta}

    Set Suite Variable        ${TOKEN}    ${resposta.json()["token"]}
    Log To Console        Token geradooooooooo: ${TOKEN}
       
    RETURN                     ${resposta.json()["token"]} 

Validar o token sysadmin e gravar autorização
    ${headers}    Create Dictionary    Authorization=${TOKEN}
    ${resposta}    GET On Session    alias=develop    url=/validateToken     headers=${headers}
    Log To Console    Resposta da Solicitação: ${resposta.json()}
    Log To Console    ${TOKEN}

Criar Sessão autorizada   
    ${headers}    Create Dictionary    accept=application/json       Content-Type=application/json     Authorization=${Token}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}

