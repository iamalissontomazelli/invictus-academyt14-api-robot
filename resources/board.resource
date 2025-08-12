*** Settings ***
Documentation        Arquivo das Bibliotecas

Library        RequestsLibrary
Library        SeleniumLibrary
Library        String
Resource      login.resource



*** Keywords ***

### Test Post #####
Criar Diretoria
    ${palavra_randomica}      Generate Random String      length=9  chars=[LETTERS]
    ${palavra_randomica}      Convert To Lower Case       ${palavra_randomica}
    Set Test Variable         ${BOARD_NAME}                B${palavra_randomica}
    Log                       ${BOARD_NAME}

Cadastrar Diretoria com Sucesso
    ${TOKEN}       Login com sysadmin 
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    Criar Diretoria
    ${body}     Create Dictionary        boardName=${BOARD_NAME}  
    ${resposta}    POST On Session        alias=develop    url=/board    json=${body}     expected_status=201   
     
    Set Suite Variable            ${Diretoria_ID}              ${resposta.json()["newBoard"]["_id"]} 


Diretoria com mais de 50 caracteres
    ${TOKEN}Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
  ${body}   Create Dictionary  boardName= Operationsd Tesdter&bhujk Operationsf Tesdter&b lOperations Tesdter&b  
  Run Keyword And Expect Error  HTTPError: 400*  POST On Session  alias=devolop   url=/board/   json=${body}
  Dictionary Should Contain Item    ${resposta.json()}    msg   O campo 'diretoria' deve possuir no máximo 50 caracteres.

  
Diretoria já cadastrada no sistema
    ${TOKEN}Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
  ${body}   Create Dictionary  boardName=Operation Tesdter&  
  Run Keyword And Expect Error  HTTPError: 409*    POST On Session  alias=develop   url=/board/   json=${body}
  ######Dictionary Should Contain Item    ${resposta.json()}    alert   Não é possível salvar esse registro. Diretoria já cadastrada no sistema.
Diretoria com caractere não permitido
     ${TOKEN}Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
  ${body}   Create Dictionary  boardName=Operation Tesdter$  
  Run Keyword And Expect Error  HTTPError: 400*  POST On Session  alias=develop   url=/board/   json=${body}
  #####Dictionary Should Contain Item    ${resposta.json()}    msg   O campo 'diretoria' deve possuir no máximo 50 caracteres.
 
 
 
##--Put--##
##__Funcional__##
Atualizar uma Diretoria por id
  Cadastrar Diretoria com Sucesso
      ${TOKEN}Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
  ${body}   Create Dictionary  boardName= New ${BOARD_NAME}  
  ${resposta}  PUT On Session  alias=develop   url=board/$${Diretoria_ID}   json=${body}
  ...    expected_status=201
   Log  ${resposta.json()}
   Dictionary Should Contain Item    ${resposta.json()}   msg   Cadastro atualizado com sucesso.
 
##__Não Funcional__##
Atulaizar diretoria com caracteres não permitidos
    ${TOKEN}Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
  Cadastrar diretoria com sucesso
  ${body}   Create Dictionary  boardName= @#$${BOARD_NAME}  
  Run Keyword And Expect Error  HTTPError: 400*  PUT On Session  alias=develop   url=/api/board/$${Diretoria_ID}   json=${body}
  Dictionary Should Contain Item    ${resposta.json()}   msg   .
Atulaizar diretoria com campo vazio
  Cadastrar diretoria com sucesso
    ${body}   Create Dictionary  boardName=  
  Run Keyword And Expect Error  HTTPError: 400*  PUT On Session  alias=develop   url=/api/board/$${Diretoria_ID}  json=${body}
  Dictionary Should Contain Item    ${resposta.json()}   msg   O campo Diretoria é obrigatório.
 
##--Get--##
##__Funcional__##
Listar diretorias
  ${resposta}  GET On Session  alias=APIConvergentes   url=/api/board/
  ...    expected_status=200  
  Log  ${resposta.json()}
 
Mostrar diretoria por id
  Cadastrar diretoria
  ${resposta}  GET On Session  alias=APIConvergentes   url=/api/board/${BOARD_ID}
  ...    expected_status=200  
  Log  ${resposta.json()}
  Should Be Equal As Strings    ${BOARD_ID}  ${resposta.json()}[board][_id]
 
##__Não Funcional__##
pesquisar Diretoria por id inválido
    Run Keyword And Expect Error  HTTPError: 500*  GET On Session  alias=APIConvergentes   url=/api/board/660340e40&17ca8b3bf6107d8  
    Dictionary Should Contain Item    ${resposta.json()}   msg   .
 
