*** Settings ***
Resource    ../../resources/company.resource
Resource        ../../resources/login.resource

*** Test Cases ***
Cadastrar Nova Company Com Sucesso
    Cadastrar Company com Sucesso
    Log    Company criada com ID: ${Company_ID}
    Should Not Be Empty    ${Company_ID}

Cadastrar Company Sem Nome
    ${resposta}=    Cadastrar Company Sem Nome
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Nome da empresa' é obrigatório.

Cadastrar Company Nome Maior Que 100 Caracteres
    ${resposta}=    Cadastrar Company Nome Maior Que 100 Caracteres
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Nome da empresa' deve ter no máximo 100 caracteres.

Cadastrar Company Nome Alfanumerico
    ${id}=    Cadastrar Company Nome Alfanumerico
    Should Not Be Empty    ${id}


Cadastrar Company Nome Duplicado
    ${resposta}=    Cadastrar Company Nome Duplicado
    Should Be Equal As Strings    ${resposta["alert"][0]}    Essa companhia já está cadastrada. Verifique o nome, CNPJ e a razão social da companhia.

Cadastrar Company Sem CNPJ
    ${resposta}=    Cadastrar Company Sem CNPJ
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa é obrigatório.

Cadastrar Company CNPJ Nao Numerico
    ${resposta}=    Cadastrar Company CNPJ Nao Numerico
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa deve conter apenas números.

Cadastrar Company CNPJ Duplicado
    ${resposta}=    Cadastrar Company CNPJ Duplicado
    Should Be Equal As Strings    ${resposta["alert"][0]}    Essa companhia já está cadastrada. Verifique o nome, CNPJ e a razão social da companhia.


Cadastrar Company CNPJ Maior Que 14 Digitos
    ${resposta}=    Cadastrar Company CNPJ Maior Que 14 Digitos
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'CNPJ' da empresa deve ter no máximo 14 caracteres numéricos.

Cadastrar Company Sem Matriz
    ${resposta}=    Cadastrar Company Sem Matriz
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Razão Social' é obrigatório.

Cadastrar Company Matriz Alfanumerica
    ${resposta}=    Cadastrar Company Matriz Alfanumerica
    Should Not Be Empty    ${resposta["newCompany"]["_id"]}

Cadastrar Company Matriz Duplicada
    ${resposta}=    Cadastrar Company Matriz Duplicada
    Should Be Equal As Strings    ${resposta["alert"][0]}    Essa companhia já está cadastrada. Verifique o nome, CNPJ e a razão social da companhia.

Cadastrar Company Matriz Maior Que 100 Caracteres
    ${resposta}=    Cadastrar Company Matriz Maior Que 100 Caracteres
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Razão Social' da empresa deve ter no máximo 100 caracteres.

Cadastrar Company Sem Contato Responsavel
    ${resposta}=    Cadastrar Company Sem Contato Responsavel
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contado do Responsável' é obrigatório.

Contato Responsavel Somente Letras
    ${resposta}=    Cadastrar Company Contato Responsavel Somente Letras
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contato do Responsável' deve ter nome e sobrenome, contendo somente letras.


Contato Responsavel Maximo 100
    ${resposta}=    Cadastrar Company Contato Responsavel Maximo 100
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contado do Responsável' deve ter no máximo 100 caracteres.

Contato Responsavel Minimo Duas Palavras
    ${resposta}=    Cadastrar Company Contato Responsavel Minimo Duas Palavras
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Contato do Responsável' deve ter nome e sobrenome, contendo somente letras.

Telefone Obrigatorio
    ${resposta}=    Cadastrar Company Telefone Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Telefone' é obrigatório.

Telefone Somente Numeros
    ${resposta}=    Cadastrar Company Telefone Somente Numeros
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Telefone' deve conter somente números.

Telefone Maximo 
    ${resposta}=    Cadastrar Company Telefone Maximo
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Telefone' deve ter entre 13 e 14 caracteres.

Email Obrigatorio
    ${resposta}=    Cadastrar Company Email Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Email' é obrigatório.

Email Formato Invalido
    ${resposta}=    Cadastrar Company Email Formato Invalido
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Email' informado é inválido. Informe um e-mail no formato [nome@domínio.com].

ServiceDescription Obrigatorio
    ${resposta}=    Cadastrar Company ServiceDescription Obrigatorio
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Descrição' é obrigatório.

ServiceDescription Nao Alfanumerico
    ${resposta}=    Cadastrar Company ServiceDescription Invalida    Loja de *Doces@2025
    Should Be Equal As Strings    ${resposta["error"][0]}    O campo 'Descrição' deve conter apenas caracteres alfanuméricos.

*** Test Cases ***
Cadastrar Company Sem Logradouro
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    Remove From Dictionary    ${body["address"]}    street   # Remove campo obrigatório
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    ${mensagem}    Set Variable    ${resposta.json()["error"][0]}
    Should Be Equal    ${mensagem}    O campo 'Logradouro' é obrigatório.

Cadastrar Company Logradouro Com Caracteres Inválidos
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    Set To Dictionary    ${body["address"]}    street=Rua @@@ Teste # Inválido (não alfanumérico permitido)
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    ${mensagem}    Set Variable    ${resposta.json()["error"][0]}
    Should Be Equal    ${mensagem}    O campo 'Logradouro' deve ser alfanumérico.

Cadastrar Company Logradouro Com Caracteres Especiais Permitidos
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    Set To Dictionary    ${body["address"]}    street=Rua 1ª Travessa-‘Centro’  # Inclui caracteres permitidos
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    ${logradouro}    Set Variable    ${resposta.json()["newCompany"]["address"]["street"]}
    Should Be Equal    ${logradouro}    Rua 1ª Travessa-‘Centro’

Cadastrar Company Logradouro Acima De 50 Caracteres
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    Set To Dictionary    ${body["address"]}    street=Rua com um nome extremamente longo que ultrapassa cinquenta caracteres
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    ${mensagem}    Set Variable    ${resposta.json()["error"][0]}
    Should Be Equal    ${mensagem}    O campo 'Logradouro' deve ter no máximo 50 caracteres.
























