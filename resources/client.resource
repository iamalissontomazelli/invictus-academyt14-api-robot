*** Settings ***
Documentation        Resource da sessão Client (schema do Swagger /client)
Library              RequestsLibrary
Library              SeleniumLibrary
Library              String
Library              Collections
Resource             login.resource

*** Keywords ***


# ---------------- Documentos a serem gerados --------------------


Gerar CPF Válido
    [Documentation]    Gera CPF válido (11 dígitos com DV) como string.
    # Gera lista de números aleatórios
    ${n}=         Evaluate    [random.randint(0,9) for _ in range(9)]    modules=random
    ${ns}=        Create Dictionary    n=${n}

    # Calcula o primeiro dígito (d1)
    ${d1}=        Evaluate    (sum([(10-i)*n[i] for i in range(9)])*10) % 11    modules=random    namespace=${ns}
    ${d1}=        Set Variable If    ${d1} == 10    0    ${d1}
    Append To List    ${n}    ${d1}
    Set To Dictionary  ${ns}   n=${n}

    # Calcula o segundo dígito (d2)
    ${d2}=        Evaluate    (sum([(11-i)*n[i] for i in range(10)])*10) % 11    modules=random    namespace=${ns}
    ${d2}=        Set Variable If    ${d2} == 10    0    ${d2}
    Append To List    ${n}    ${d2}

    # Junta todos os números e transformar em string
    ${ns}=        Create Dictionary    n=${n}
    ${cpf}=       Evaluate    ''.join(map(str, n))    namespace=${ns}
    RETURN        ${cpf}

Gerar RG Aleatorio
    [Documentation]    Gera RG simples com 7 dígitos.
    ${rg}=    Generate Random String    length=7    chars=[NUMBERS]
    RETURN   ${rg}

# ---------------- Documentos principais a serem gerados  -----------------------

Criar Cliente - Dados Válidos
    [Documentation]    Gera dados válidos conforme o Swagger (fullName, birthDate, mail, phone, currentRole, documents[], address[]).

    # ---------------- Campos aleatórios para diferenciar cada teste ----------------
    ${rlet}=          Generate Random String    length=6    chars=[LETTERS]
    ${rlet}=          Convert To Lower Case     ${rlet}
    ${rnum}=          Generate Random String    length=9    chars=[NUMBERS]

    # ---------------- Campos básicos ----------------
    Set Test Variable    ${FULL_NAME}       Cliente ${rlet}
    Set Test Variable    ${BIRTH_DATE}      24082023    # formato aceito pelo backend: apenas números
    Set Test Variable    ${MAIL}            ${rlet}.qa@exemplo.com
    Set Test Variable    ${PHONE}           5591${rnum}    # código + número aleatório
    Set Test Variable    ${CURRENT_ROLE}    ADMIN

    # ---------------- Documentos ----------------
    ${CPF}=             Gerar CPF Válido
    ${RG}=              Gerar RG Aleatorio
    ${doc}=             Create Dictionary    rg=${RG}    cpf=${CPF}
    ${DOCS_LIST}=       Create List          ${doc}
    Set Test Variable   ${DOCS_LIST}         ${DOCS_LIST}

    # ---------------- Endereço ----------------
    ${NUMERO_STR}=      Generate Random String    length=3    chars=[NUMBERS]
    ${NUMERO}=          Convert To Integer    ${NUMERO_STR}    # envia como número puro (int)
    ${addr}=            Create Dictionary
    ...                 country=Brasil
    ...                 zipCode=61025639
    ...                 city=Belém
    ...                 state=PA
    ...                 district=São Brás
    ...                 street=Rua 3 de Maio
    ...                 number=${NUMERO}
    ...                 complement=Hospital do Coração
    ${ADDR_LIST}=       Create List          ${addr}
    Set Test Variable   ${ADDR_LIST}         ${ADDR_LIST}

# ---------------- Sessão Autenticada de Cliente ------------------

Criar Sessão Autenticada Client
    [Documentation]    Login e criação de sessão com Authorization.
    ${TOKEN}=          Login com sysadmin
    ${headers}=        Create Dictionary
    ...                accept=application/json
    ...                Content-Type=application/json
    ...                Authorization=${TOKEN}
    Create Session     alias=develop        url=${baseURL}    headers=${headers}    verify=true

# ---------------- Criacao de Body -------------------------

Montar Body Cliente (Valido)
    [Documentation]    Monta o JSON conforme o Example do Swagger.
    ${body}=     Create Dictionary
    ...          fullName=${FULL_NAME}
    ...          birthDate=${BIRTH_DATE}
    ...          mail=${MAIL}
    ...          phone=${PHONE}
    ...          currentRole=${CURRENT_ROLE}
    ...          documents=${DOCS_LIST}
    ...          address=${ADDR_LIST}
    RETURN       ${body}

# ---------------- Teste principal --------------------------

Cadastrar Cliente com Sucesso
    [Documentation]    POST /client com body válido → espera 201 e guarda o _id.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)

    Log    BODY /client: ${body}
    ${resposta}=    POST On Session    alias=develop    url=/client    json=${body}    expected_status=201
    Log    RESP /client: ${resposta.json()}

    # Ajuste se o caminho do ID for diferente no seu backend
    Set Suite Variable    ${CLIENTE_ID}    ${resposta.json()["newClient"]["_id"]}



# ---------------(PUT) ------------

Atualizar Cliente por Id (Sucesso)
    [Documentation]    PUT /client/{id} com body válido → espera 200 (ajuste se seu backend usar 201).
    # Pré-condição: criar um cliente e guardar ${CLIENTE_ID}
    Cadastrar Cliente com Sucesso
    ${novo_phone}=    Generate Random String    length=10    chars=[NUMBERS]
    ${novo_rg}=       Generate Random String    length=7     chars=[NUMBERS]
    ${novo_cpf}=      Gerar CPF Válido

    # Novo bloco de documentos/endereço (mantendo schema do Swagger)
    ${doc2}=          Create Dictionary    rg=${novo_rg}    cpf=${novo_cpf}
    ${DOCS2}=         Create List          ${doc2}
    ${novo_num}=      Convert To Integer   ${novo_phone[0:3]}     # só pra gerar um número "novo" para endereço
    ${addr2}=         Create Dictionary
    ...               country=Brasil
    ...               zipCode=01001000
    ...               city=São Paulo
    ...               state=SP
    ...               district=Centro
    ...               street=Rua Teste Atualizado
    ...               number=${novo_num}
    ...               complement=Andar 2
    ${ADDR2}=         Create List          ${addr2}

    ${body_put}=      Create Dictionary
    ...               fullName=${FULL_NAME}      # mantém o nome
    ...               birthDate=${BIRTH_DATE}    # mantém a data
    ...               mail=${MAIL}               # mantém e-mail
    ...               phone=5591${novo_phone}    # altera phone
    ...               currentRole=USER           # muda role para ver efeito
    ...               documents=${DOCS2}
    ...               address=${ADDR2}

    ${resp}=          PUT On Session    alias=develop    url=/client/${CLIENTE_ID}    json=${body_put}    expected_status=200
    Log               RESP PUT: ${resp.json()}

#                 -----   GET    ------ 

Listar Clientes (Sucesso)
    [Documentation]    GET /client → 200
    ${resp}=          GET On Session    alias=develop    url=/client    expected_status=200
    Log               RESP GET LIST: ${resp.json()}

Buscar Cliente por Id (Sucesso)
    [Documentation]    GET /client/{id} → 200 e confere _id
    # Pré-condição: ter um cliente criado
    Cadastrar Cliente com Sucesso
    ${resp}=          GET On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=200
    Log               RESP GET ID: ${resp.json()}
    # Ajuste a expressão se sua API retornar com outra chave
    Should Be Equal As Strings    ${CLIENTE_ID}    ${resp.json()["client"]["_id"]}


#                 -----   DELETE    ------

Remover Cliente por Id (Sucesso)
    [Documentation]    DELETE /client/{id} → 200/204 (ajuste conforme o backend; aqui uso 200)
    # Pré-condição: ter um cliente criado
    Cadastrar Cliente com Sucesso
    ${resp}=          DELETE On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=200
    Log               RESP DELETE: ${resp.json()}


#                 -----   Casos simples invalido    (Caso seja necessário)    ------

Buscar Cliente por Id Inválido (400/404)
    [Documentation]    GET /client/{id inválido} → espera 400 ou 404 (ajuste se necessário)
    ${id_invalido}=    Set Variable    660340e40&17ca8b3bf6107d8    # formato inválido comum
    Run Keyword And Expect Error    HTTPError: 4*    GET On Session    alias=develop    url=/client/${id_invalido}

Atualizar Cliente com Body Inválido (400)
    [Documentation]    PUT /client/{id} com campos inválidos → 400
    Cadastrar Cliente com Sucesso
    ${body}=           Create Dictionary
    ...                fullName=           # vazio
    ...                birthDate=abc123    # inválido
    ...                mail=usuario@@dominio
    ...                phone=(11) 99999-9999
    ...                currentRole=123##
    ...                documents=${EMPTY}  # vazio
    ...                address=${EMPTY}
    Run Keyword And Expect Error    HTTPError: 400*    PUT On Session    alias=develop    url=/client/${CLIENTE_ID}    json=${body}


# ========================= DELETE =========================
Remover Cliente por Id (Sucesso)
    [Documentation]    DELETE /client/{id} → remove o cliente e valida que não existe mais.
    # 1) Pré-condição: cria um cliente e guarda ${CLIENTE_ID}
    Cadastrar Cliente com Sucesso

    # 2) Tenta deletar aceitando 200 OU 204 (alguns backends variam)
    ${ok200}=    Run Keyword And Return Status
    ...          DELETE On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=200
    Run Keyword If    not ${ok200}
    ...    DELETE On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=204

    # 3) Confirma que realmente foi removido (GET deve falhar com 404)
    Run Keyword And Expect Error    HTTPError: 404*    GET On Session    alias=develop    url=/client/${CLIENTE_ID}