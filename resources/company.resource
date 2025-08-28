*** Settings ***
Documentation        Recursos para testar API Company
Library    RequestsLibrary
Library    SeleniumLibrary
Library    String
Library    Collections
Library    BuiltIn
Resource    login.resource

*** Variables ***
${baseURL}    https://api-invictus.qacoders.dev.br/api

*** Keywords ***

#GET


Listar Todas Companies
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Buscar Company Por ID
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company/${company_id}    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Contar Companies
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${resposta}    GET On Session    alias=develop    url=/company/count    expected_status=200
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

#POST


Criar Company
    # Gerar nomes aleatórios para empresa e responsável
    ${nome1_raw}    Generate Random String    length=6    chars=[LOWER]
    ${nome1}        Convert To Title Case    ${nome1_raw}

    ${nome2_raw}    Generate Random String    length=8    chars=[LOWER]
    ${nome2}        Convert To Title Case    ${nome2_raw}

    ${responsavel}  Set Variable    ${nome1} ${nome2}
    Should Match Regexp    ${responsavel}    [A-Z][a-z]+ [A-Z][a-z]

    #${telefone_random}    Set Variable    +5551997999999



    ${cnpj_random}    Evaluate    ''.join([str(random.randint(0,9)) for _ in range(14)])    modules=random


    # Número aleatório para endereço
    ${numero_random}       Evaluate    random.randint(1, 9999999999)    modules=random
    ${cep_random}          Evaluate    random.choice(["04777001", "01001000", "12345678"])    modules=random
    ${cidade_random}       Evaluate    random.choice(["São Paulo", "Rio de Janeiro", "Curitiba"])    modules=random
    ${estado_random}       Evaluate    random.choice(["SP", "RJ", "PR"])    modules=random
    ${bairro_random_raw}   Generate Random String    length=8    chars=[LOWER]
    ${bairro_random}       Convert To Title Case    ${bairro_random_raw}
    ${rua_random_raw}      Generate Random String    length=12   chars=[LOWER]
    ${rua_random}          Convert To Title Case    ${rua_random_raw}
    ${complemento_numero}  Evaluate    random.randint(1, 500)    modules=random
    ${complemento_random}  Set Variable             Apt ${complemento_numero}

    # Criar corpo do request
    ${body}    Create Dictionary
    ...    corporateName=Empresa ${nome1}
    ...    registerCompany=${cnpj_random}
    ...    mail=test${nome1.lower()}@teste.com
    ...    matriz=Matriz ${nome1}
    ...    responsibleContact=${responsavel}
    ...    telephone=+551991982985
    ...    serviceDescription=Serviço de ${nome1}
    ...    address=@{EMPTY}

    ${endereco}    Create Dictionary
    ...    zipCode=${cep_random}
    ...    city=${cidade_random}
    ...    state=${estado_random}
    ...    district=${bairro_random}
    ...    street=${rua_random}
    ...    number=${numero_random}
    ...    complement=${complemento_random}
    ...    country=Brasil

    Append To List    ${body["address"]}    ${endereco}

    RETURN    ${body}




Cadastrar Company com Sucesso
    ${TOKEN}    Login com sysadmin
    ${headers}  Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    ${body}    Criar Company
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Log    Resposta da API: ${resposta.text}
    RETURN    ${resposta.json()}


#Testes negativos

Cadastrar Company Sem Nome
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    Remove From Dictionary    ${body}    corporateName  
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Nome Maior Que 100 Caracteres
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true
    
    ${body}    Criar Company
    # Criar string com 101 caracteres
    ${nome_long}    Generate Random String    length=101    chars=[LETTERS]
    Set To Dictionary    ${body}    corporateName=${nome_long}
    
    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Nome Alfanumerico
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session  alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=        Criar Company
    # Gerar corporateName aleatório com letras + números
    ${nome_random}    Generate Random String    length=6    chars=[LOWER]
    ${numero_random}  Generate Random String    length=4    chars=[NUMBERS]
    ${corporate_name}    Set Variable    Testando ${nome_random}${numero_random}
    Set To Dictionary    ${body}    corporateName=${corporate_name}

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Log    Resposta da API: ${resposta.text}

    # Retornar a mensagem de sucesso
    RETURN    ${resposta.json()["msg"]}



Cadastrar Company Nome Duplicado
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    # Criar a primeira empresa
    ${body1}=    Criar Company
    ${resposta1}=    POST On Session    alias=develop    url=/company    json=${body1}    expected_status=201
    ${nome}=    Set Variable    ${body1["corporateName"]}

    # Criar segunda empresa com o mesmo nome
    ${body2}=    Criar Company
    Set To Dictionary    ${body2}    corporateName=${nome}
    Set To Dictionary    ${body2}    registerCompany=99999999000199  
    ${resposta2}=    POST On Session    alias=develop    url=/company    json=${body2}    expected_status=400
    Log    ${resposta2.json()}
    RETURN    ${resposta2.json()}

Cadastrar Company Sem CNPJ
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company
    # Remover o CNPJ para testar obrigatoriedade
    Set To Dictionary    ${body}    registerCompany=

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company CNPJ Nao Numerico
    ${TOKEN}       Login com sysadmin
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company
    # Inserir CNPJ inválido com letras
    ${cnpj_aleatorio}=    Generate Random String    length=14    chars=[LETTERS]
    Set To Dictionary    ${body}    registerCompany=${cnpj_aleatorio}

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company CNPJ Duplicado
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    # --- Primeiro cadastro (empresa aleatória) ---
    ${body1}=    Criar Company
    ${cnpj}=     Generate Random String    length=14    chars=[NUMBERS]
    Set To Dictionary    ${body1}    registerCompany=${cnpj}

    ${resposta1}=    POST On Session    alias=develop    url=/company    json=${body1}    expected_status=201

    # --- Segundo cadastro (mesmo CNPJ, mesma razão social e corporateName) ---
    ${body2}=    Create Dictionary
    ...    corporateName=${body1['corporateName']}
    ...    registerCompany=${body1['registerCompany']}
    ...    serviceDescription=${body1['serviceDescription']}
    ...    responsibleContact=${body1['responsibleContact']}
    ...    mail=${body1['mail']}
    ...    matriz=${body1['matriz']}
    ...    telephone=${body1['telephone']}
    ...    address=${body1['address']}

    # --- Enviar segundo POST e validar 400 ---
    ${resposta2}=    POST On Session    alias=develop    url=/company    json=${body2}    expected_status=400
    Log    ${resposta2.json()}
    RETURN    ${resposta2.json()}

Cadastrar Company CNPJ Maior Que 14 Digitos
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    # Criar empresa aleatória
    ${body}=    Criar Company

   
    ${cnpj_grande}=    Generate Random String    length=15    chars=[NUMBERS]
    Set To Dictionary    ${body}    registerCompany=${cnpj_grande}

    
    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Sem Matriz
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    
    ${body}=    Criar Company

    # Remover a matriz (razão social)
    Remove From Dictionary    ${body}    matriz

   
    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}


Cadastrar Company Matriz Alfanumerica
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session  alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=        Criar Company
    # Gerar corporateName aleatório para matriz com letras + números
    ${nome_random}    Generate Random String    length=6    chars=[LOWER]
    ${numero_random}  Generate Random String    length=4    chars=[NUMBERS]
    ${corporate_name}    Set Variable    Matriz ${nome_random}${numero_random}
    Set To Dictionary    ${body}    corporateName=${corporate_name}

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Log    Resposta da API: ${resposta.text}

    # Retornar a mensagem de sucesso
    RETURN    ${resposta.json()["msg"]}


Cadastrar Company Matriz Duplicada
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    
    ${body1}=    Criar Company
    ${resposta1}=    POST On Session    alias=develop    url=/company    json=${body1}    expected_status=201

    
    ${matriz_dup}=    Set Variable    ${body1["matriz"]}

   
    ${body2}=    Criar Company
    Set To Dictionary    ${body2}    matriz=${matriz_dup}

    # Garantir que corporateName e CNPJ sejam diferentes
    ${nome_random}=    Generate Random String    length=6    chars=[LOWER]
    Set To Dictionary    ${body2}    corporateName=Empresa ${nome_random}
    ${cnpj_random}=    Generate Random String    length=14    chars=[NUMBERS]
    Set To Dictionary    ${body2}    registerCompany=${cnpj_random}

    
    ${resposta2}=    POST On Session    alias=develop    url=/company    json=${body2}    expected_status=400
    Log    ${resposta2.json()}
    RETURN    ${resposta2.json()}

Cadastrar Company Matriz Maior Que 100 Caracteres
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    
    ${body}=    Criar Company

   
    ${matriz_long}=    Generate Random String    length=101    chars=[LETTERSNUMBERS]
    Set To Dictionary    ${body}    matriz=${matriz_long}

    
    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Sem Contato Responsavel
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    
    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    responsibleContact=

    
    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Contato Responsavel Somente Letras
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

   
    Set To Dictionary    ${body}    responsibleContact=Marcia123

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}


Cadastrar Company Contato Responsavel Maximo 100
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    ${responsavel_long}=    Generate Random String    length=101    chars=[LETTERS]
    Set To Dictionary    ${body}    responsibleContact=${responsavel_long}

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Contato Responsavel Minimo Duas Palavras
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    responsibleContact=Marcia

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Telefone Obrigatorio
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    telephone=

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Telefone Somente Numeros
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    telephone=5511ABCD5678

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}



Cadastrar Company Telefone Maximo 
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    telephone=551198765432123

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Email Obrigatorio
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    # Remover e-mail
    Set To Dictionary    ${body}    mail=

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

Cadastrar Company Email Formato Invalido
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company

    
    Set To Dictionary    ${body}    mail=teste@@dominio..com

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    RETURN    ${resposta.json()}

*** Keywords ***

Cadastrar Company ServiceDescription Obrigatorio
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company
    Set To Dictionary    ${body}    serviceDescription=

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Cadastrar Company ServiceDescription Invalida
    [Arguments]    ${descricao_invalida}
    ${TOKEN}=    Login com sysadmin
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}=    Criar Company
    Set To Dictionary    ${body}    serviceDescription=${descricao_invalida}

    ${resposta}=    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Logradouro Campo Obrigatório
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Criar Company
    # Remove o campo street do primeiro endereço
    Remove From Dictionary    ${body["address"][0]}    street

    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'Logradouro' é obrigatório.


Logradouro Somente Alfanumérico
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Criar Company
    # Define caracteres inválidos no primeiro endereço
    Set To Dictionary    ${body["address"][0]}    street    @@@###

    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'Logradouro' deve ser alfanumérico.


Cadastrar Company Logradouro Com Caracteres Especiais Permitidos
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Criar Company
    # Usando apenas caracteres válidos exatos: letras, números, 'ª', 'º', '-' (evitar aspas curvas)
    Set To Dictionary    ${body["address"][0]}    street    Rua 1ª Travessa-Centro

    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=201
    Log    ${resposta.json()}



    

Logradouro Máximo 50 Caracteres
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    alias=develop    url=${baseURL}    headers=${headers}    verify=true

    ${body}    Criar Company
    ${logradouro_invalido}=    Evaluate    "A" * 51
    Set To Dictionary    ${body["address"][0]}    street    ${logradouro_invalido}

    ${resposta}    POST On Session    alias=develop    url=/company    json=${body}    expected_status=400
    Log    ${resposta.json()}
    Should Be Equal    ${resposta.json()["error"][0]}    O campo 'Logradouro' deve ter no máximo 50 caracteres.

#PUT 

Atualizar Company Com Sucesso
    [Arguments]    ${company_id}
    ${TOKEN}=       Login com sysadmin
    ${headers}=     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session  alias=develop    url=${baseURL}    headers=${headers}    verify=true

    # Gerar dados válidos
    ${rand_nome}=           Generate Random String    6    [LETTERS]
    ${rand_cnpj}=           Generate Random String    14    [NUMBERS]
    ${rand_matriz}=         Generate Random String    5    [LETTERS]
    ${rand_responsavel}=    Generate Random String    6    [LETTERS]
    ${rand_telefone_num}=   Generate Random String    9    [NUMBERS]
    ${rand_servico}=        Generate Random String    8    [LETTERS]
    ${rand_razao}=          Generate Random String    10    [LETTERS]

    # Montar campos com formato aceito
    ${responsavel}=    Set Variable    ${rand_nome.title()} ${rand_responsavel.title()}
    ${telefone}=       Set Variable    +5511${rand_telefone_num}

  

    # Criar body com address aninhado
    ${body}=    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz ${rand_matriz}
    ...    responsibleContact=${responsavel}
    ...    telephone=${telefone}
    ...    mail=${rand_nome}@teste.com
    ...    serviceDescription=Serviço ${rand_servico}
    ...    razao=Razao ${rand_razao}

    ${resposta}=    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=200
    ${updated}=    Set Variable    ${resposta.json()["updatedCompany"]}
    Log To Console    ${updated}
    RETURN    ${updated}






# Testes negativos

Atualizar Company Nome Vazio
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_cnpj}           Generate Random String    14   chars=[NUMBERS]
    ${rand_responsavel}    Generate Random String    6    chars=[LOWER]
    ${rand_telefone}       Set Variable    5511${123456789}
    ${rand_email}          Set Variable    teste${rand_responsavel}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano ${rand_responsavel}
    ...    telephone=${rand_telefone}
    ...    mail=${rand_email}
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company CNPJ Invalido
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_email}   Set Variable    ${rand_nome}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=12345
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano Teste
    ...    telephone=5511999999999
    ...    mail=${rand_email}
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company Razao Social Vazia
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_cnpj}    Generate Random String    14   chars=[NUMBERS]
    ${rand_email}   Set Variable    ${rand_nome}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano Teste
    ...    telephone=5511999999999
    ...    mail=${rand_email}
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company Contato Invalido
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_cnpj}    Generate Random String    14   chars=[NUMBERS]
    ${rand_email}   Set Variable    ${rand_nome}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=123456
    ...    telephone=5511999999999
    ...    mail=${rand_email}
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company Telefone Invalido
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_cnpj}    Generate Random String    14   chars=[NUMBERS]
    ${rand_email}   Set Variable    ${rand_nome}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano Teste
    ...    telephone=ABCDE
    ...    mail=${rand_email}
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company Email Invalido
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_cnpj}    Generate Random String    14   chars=[NUMBERS]

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano Teste
    ...    telephone=5511999999999
    ...    mail=email-invalido
    ...    serviceDescription=Serviço Teste
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

Atualizar Company Descricao Vazia
    [Arguments]    ${company_id}
    ${TOKEN}       Login com sysadmin
    ${headers}     Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session    develop    ${baseURL}    headers=${headers}    verify=true

    ${rand_nome}    Generate Random String    8    chars=[LOWER]
    ${rand_cnpj}    Generate Random String    14   chars=[NUMBERS]
    ${rand_email}   Set Variable    ${rand_nome}@teste.com

    ${body}    Create Dictionary
    ...    corporateName=Empresa ${rand_nome}
    ...    registerCompany=${rand_cnpj}
    ...    matriz=Matriz Teste
    ...    responsibleContact=Fulano Teste
    ...    telephone=5511999999999
    ...    mail=${rand_email}
    ...    serviceDescription=
    ...    corporateReason=Razao Teste
    ...    address={"zipCode": "12345678", "city": "São Paulo", "state": "SP", "street": "Rua Teste", "number": 123, "country": "Brasil"}

    ${resposta}    PUT On Session    develop    /company/${company_id}    json=${body}    expected_status=400
    RETURN    ${resposta.json()}

