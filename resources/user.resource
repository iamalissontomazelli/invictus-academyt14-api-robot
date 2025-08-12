*** Settings ***
Documentation    REcursos para testes user
Library        RequestsLibrary
Library        String
Library        Collections
Resource       login.resource


*** Keywords ***
Cadastrar novo usuario
    ${TOKEN}     Login com sysadmin 

    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json      Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Create Dictionary          
    ...    fullName=Margaridadois Teste
    ...    mail=margaridadoisteste@teste.com.br
    ...    accessProfile=ADMIN
    ...    cpf=98292988873
    ...    password=6345@Test
    ...    confirmPassword=6345@Test
        
    ${resposta}    POST On Session    alias=develop    url=user/         json=${body}     
      Log To Console        RESPOSTA JSON: ${resposta.json()}
      Log  ${resposta.json()}
      Set Test Variable    ${ID_USUARIO}  ${resposta.json()["user"]["_id"]}
      Set Test Variable    ${FULLNAME}  ${resposta.json()["user"]["fullName"]}
      Set Test Variable    ${RESPOSTA}  ${resposta.json()}
      Dictionary Should Contain Item    ${RESPOSTA}    msg    Olá ${FULLNAME}, cadastro realizado com sucesso.
      Log To Console    ID_USUARIO: ${ID_USUARIO}
      Log To Console    FULLNAME: ${FULLNAME}

Listagem de Usuário
    ${TOKEN}        Login com sysadmin
    ${headers}      Create Dictionary    accept=application/json         Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    GET On Session     alias=develop    url=user/  
    Log To Console    LISTAGEM USUARIO:${resposta.json()}


Contagem de Usuário
    ${TOKEN}        Login com sysadmin
    ${headers}      Create Dictionary    accept=application/json         Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    GET On Session     alias=develop    url=user/count 
    Log To Console    CONTAGEM USUARIO:${resposta.json()}