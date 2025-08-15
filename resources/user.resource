*** Settings ***
Documentation    Recursos para testes user
Library        RequestsLibrary
Library        String
Library        Collections
Resource       login.resource


*** Keywords ***
Login com Usuário
    ${TOKEN}     Login com sysadmin
    Criar User
    Cadastrar novo usuario
    ${body}=         Create Dictionary
    ...              mail=${EMAIL}
    ...              password=1234@Test
    Criar Sessão
    ${resposta}=     POST On Session    alias=develop    url=/login    json=${body}    
    Status Should Be    200    ${resposta}
    Set Suite Variable    ${USER_TOKEN}    ${resposta.json()["token"]}
    RETURN            ${resposta.json()["token"]}

Criar User
    ${palavra_randomica}      Generate Random String      length=8  chars=[LETTERS]
    ${palavra_randomica}      Convert To Lower Case       ${palavra_randomica}
    Set Test Variable         ${USER_NAME}                B${palavra_randomica}
    Set Test Variable         ${SUR_NAME}                 L${palavra_randomica}
    Set Test Variable         ${FULL_NAME}                B${palavra_randomica} L${palavra_randomica}
   
    Set Test Variable    ${EMAIL}    ${palavra_randomica}@qacoders.com

    ${numero_randomico}      Generate Random String      length=11  chars=[NUMBERS]
    Set Test Variable         ${CPF}                ${numero_randomico} 
Cadastrar novo usuario
    Criar User
    ${TOKEN}     Login com sysadmin 

    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json      Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Create Dictionary          
    ...    fullName=${FULL_NAME}
    ...    mail=${EMAIL}
    ...    accessProfile=ADMIN
    ...    cpf=${CPF}
    ...    password=1234@Test
    ...    confirmPassword=1234@Test
        
    ${resposta}    POST On Session    alias=develop    url=user/       json=${body}     
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

Mostrar Usuário
    Cadastrar novo usuario
    ${TOKEN}        Login com sysadmin
    ${headers}      Create Dictionary    accept=application/json         Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    GET On Session     alias=develop    url=user/${ID_USUARIO}?token=${TOKEN}
    Log To Console    BUSCAR USUARIO:${resposta.json()}

Deletar os dados do usuário
    Cadastrar novo usuario
    ${TOKEN}        Login com sysadmin
    ${headers}      Create Dictionary    accept=application/json         Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    DELETE On Session     alias=develop    url=user/${ID_USUARIO}?token=${TOKEN}
    Log To Console    DELETAR USUARIO:${resposta.json()}
Atualizar senha do usuário
    ${TOKEN}        Login com sysadmin
    Cadastrar novo usuario
    ${USER_TOKEN}    Login com Usuário

    ${body}=         Create Dictionary
    ...              password=12345@Test
    ...              confirmPassword=12345@Test
       
    ${headers}      Create Dictionary    accept=application/json         Authorization=${USER_TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    Put On Session     alias=develop    url=user/password/${ID_USUARIO}    json=${body}
    Log To Console    ATUALIZAR USUARIO:${resposta.json()}

Atualizar status do usuário
    Cadastrar novo usuario
    ${TOKEN}        Login com sysadmin
    ${headers}      Create Dictionary    accept=application/json         Authorization=${TOKEN} 
    Create Session        alias=develop    url=${baseURL}    headers=${headers}    verify=true
  
    ${resposta}    Put On Session     alias=develop    url=user/status/${ID_USUARIO}?token=${TOKEN}
    Log To Console    ATUALIZAR USUARIO:${resposta.json()}





