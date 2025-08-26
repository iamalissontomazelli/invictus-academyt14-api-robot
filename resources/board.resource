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
     Log To Console    ********ID DIRETORIA: ${Diretoria_ID}


Diretoria com mais de 50 caracteres 
     ${TOKEN}       Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Criar Diretoria
      ${body}   Create Dictionary  boardName= Operationsd Tesdter&bhujk Operationsf Tesdter&b lOperations Tesdter&b  
      ${resposta}    POST On Session        alias=develop    url=/board    json=${body}     expected_status=400 
      Should Be Equal As Integers    ${resposta.status_code}    400
      ${mensagem_erro} =    Set Variable    ${resposta.json()["error"][0]}
      Should Be Equal As Strings    ${mensagem_erro}    O campo 'diretoria' deve possuir no máximo 50 caracteres.

  
Diretoria já cadastrada no sistema
    ${TOKEN}    Login com sysadmin 
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    Criar Diretoria
    ${body}   Create Dictionary  boardName=Operation Tesdter&  
    ${resposta}    POST On Session        alias=develop    url=/board    json=${body}     expected_status=409 
    Should Be Equal As Integers    ${resposta.status_code}    409 
    ${mensagem_erro} =    Set Variable    ${resposta.json()["alert"][0]}    
    Should Be Equal As Strings    ${mensagem_erro}    Não é possível salvar esse registro. Diretoria já cadastrada no sistema.

  # Run Keyword And Expect Error  HTTPError: 409*    POST On Session  alias=develop   url=/board/   json=${body}
  ######Dictionary Should Contain Item    ${resposta.json()}    alert   Não é possível salvar esse registro. Diretoria já cadastrada no sistema.
Cadastrar diretoria com campo vazio
     ${TOKEN}      Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Criar Diretoria
     ${body}   Create Dictionary  boardName= 
     ${resposta}    POST On Session        alias=develop    url=/board    json=${body}     expected_status=400 
    Should Be Equal As Integers    ${resposta.status_code}    400 
    ${mensagem_erro} =    Set Variable    ${resposta.json()["error"][0]}    
    Should Be Equal As Strings    ${mensagem_erro}    O campo 'diretoria' é obrigatório.
 



Diretoria com caractere não permitido
     ${TOKEN}      Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Criar Diretoria
     ${body}   Create Dictionary  boardName=Operation Tesdter$  
     ${resposta}    POST On Session        alias=develop    url=/board    json=${body}     expected_status=400 
    Should Be Equal As Integers    ${resposta.status_code}    400 
    ${mensagem_erro} =    Set Variable    ${resposta.json()["error"][0]}    
    Should Be Equal As Strings    ${mensagem_erro}    O campo 'diretoria' só pode conter letras e o caractere especial '&'.
 
 
 
##--Put--##
##__Funcional__##
Atualizar uma Diretoria por id
     ${TOKEN}      Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Criar Diretoria
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     ${body}   Create Dictionary  boardName= New ${BOARD_NAME}  
     ${resposta}  PUT On Session  alias=develop   url=board/${Diretoria_ID}   json=${body}    expected_status=200
     Log      MENSAGEMMMMMMMMMMMMM:${resposta.json()}
     Dictionary Should Contain Item    ${resposta.json()}   msg   Cadastro atualizado com sucesso.
 
##__Não Funcional__##
Atulaizar diretoria com caracteres não permitidos
     ${TOKEN}       Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Criar Diretoria
     ${body}   Create Dictionary  boardName= @#$${BOARD_NAME}  
     ${resposta}  PUT On Session  alias=develop   url=board/${Diretoria_ID}   json=${body}    expected_status=200
     Log      MENSAGEMMMMMMMMMMMMM:${resposta.json()}
     Dictionary Should Contain Item    ${resposta.json()}   msg   Cadastro atualizado com sucesso.

Atulaizar diretoria com campo vazio
  Cadastrar diretoria com sucesso
  ${body}   Create Dictionary  boardName=  
  Run Keyword And Expect Error  HTTPError: 400*  PUT On Session  alias=develop   url=/api/board/$${Diretoria_ID}  json=${body}
  Dictionary Should Contain Item    ${resposta.json()}   msg   O campo Diretoria é obrigatório.
  
 
##--Get--##
##__Funcional__##
Listar diretorias
    ${TOKEN}       Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Cadastrar diretoria com sucesso
      ${resposta}  GET On Session  alias=develop   url=board/        expected_status=200  
  
 
Mostrar diretoria por id
     ${TOKEN}       Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Cadastrar Diretoria com Sucesso
     ${resposta}  GET On Session  alias=develop  url=board/${Diretoria_ID}     expected_status=200 
     Set Suite Variable            ${MOSTRAR_Diretoria_ID}              ${resposta.json()["board"]["_id"]} 
    
 
##__Não Funcional__##
pesquisar Diretoria por id inválido
     ${TOKEN}       Login com sysadmin 
     ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
     Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
     Cadastrar Diretoria com Sucesso
     ${resposta}      GET On Session      alias=develop      url=board/689f8171e56b350eb670d943         expected_status=400
     Set Suite Variable            ${MOSTRAR_Diretoria_ID}              ${resposta.json()["msg"]} 
     