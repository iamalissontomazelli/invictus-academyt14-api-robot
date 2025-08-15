*** Settings ***
Documentation        Resource da sessão Client (schema do Swagger /client)
Library              RequestsLibrary
Library              SeleniumLibrary
Library              String
Library              Collections
Resource             login.resource

*** Keywords ***

# ---------------- Helpers de documentos ----------------
Gerar CPF Válido
    [Documentation]    Gera CPF válido (11 dígitos com DV) como string.
    ${n}=         Evaluate    [random.randint(0,9) for _ in range(9)]    modules=random
    ${ns}=        Create Dictionary    n=${n}

    ${d1}=        Evaluate    (sum([(10-i)*n[i] for i in range(9)])*10) % 11    modules=random    namespace=${ns}
    ${d1}=        Set Variable If    ${d1} == 10    0    ${d1}
    Append To List    ${n}    ${d1}
    Set To Dictionary  ${ns}   n=${n}

    ${d2}=        Evaluate    (sum([(11-i)*n[i] for i in range(10)])*10) % 11    modules=random    namespace=${ns}
    ${d2}=        Set Variable If    ${d2} == 10    0    ${d2}
    Append To List    ${n}    ${d2}

    ${ns}=        Create Dictionary    n=${n}
    ${cpf}=       Evaluate    ''.join(map(str, n))    namespace=${ns}
    RETURN        ${cpf}
Gerar RG Aleatorio
    [Documentation]    Gera RG simples com 7 dígitos.
    ${rg}=    Generate Random String    length=7    chars=[NUMBERS]
    [Return]   ${rg}

# ---------------- Helpers principais ----------------
Criar Cliente - Dados Válidos
    [Documentation]    Gera dados válidos conforme o Swagger (fullName, birthDate, mail, phone, currentRole, documents[], address[]).
    ${rlet}=          Generate Random String    length=6    chars=[LETTERS]
    ${rlet}=          Convert To Lower Case     ${rlet}
    ${rnum}=          Generate Random String    length=9    chars=[NUMBERS]

    # Básicos
    Set Test Variable    ${FULL_NAME}       Cliente ${rlet}
    Set Test Variable    ${BIRTH_DATE}      24082023          # somente dígitos, formato aceito pelo backend
    Set Test Variable    ${MAIL}            ${rlet}.qa@exemplo.com
    Set Test Variable    ${PHONE}           5591${rnum}       # numérico
    Set Test Variable    ${CURRENT_ROLE}    ADMIN

    # Documents (CPF VÁLIDO e único, RG aleatório)
    ${CPF}=             Gerar CPF Válido
    ${RG}=              Gerar RG Aleatorio
    ${doc}=             Create Dictionary    rg=${RG}    cpf=${CPF}
    ${DOCS_LIST}=       Create List          ${doc}
    Set Test Variable   ${DOCS_LIST}         ${DOCS_LIST}

    # Address (array com 1 objeto)
    ${addr}=            Create Dictionary
    ...                 country=Brasil
    ...                 zipCode=61025639
    ...                 city=Belém
    ...                 state=PA
    ...                 district=São Brás
    ...                 street=Rua 3 de Maio
    ...                 number=27
    ...                 complement=Hospital do Coração
    ${ADDR_LIST}=       Create List          ${addr}
    Set Test Variable   ${ADDR_LIST}         ${ADDR_LIST}

Criar Sessão Autenticada Client
    [Documentation]    Login e criação de sessão com Authorization.
    ${TOKEN}=          Login com sysadmin
    ${headers}=        Create Dictionary    accept=application/json    Content-Type=application/json    Authorization=${TOKEN}
    Create Session     alias=develop        url=${baseURL}            headers=${headers}    verify=true

# ---------- Body Builder (igual ao schema do Swagger) ----------
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
    [Return]     ${body}

### Test Post #####
Cadastrar Cliente com Sucesso
    [Documentation]    POST /client com body do Swagger → espera 201 e guarda o _id.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)

    Log    BODY /client: ${body}
    ${resposta}=    POST On Session    alias=develop    url=/client    json=${body}    expected_status=201
    Log    RESP /client: ${resposta.json()}

    # Ajuste se o caminho do ID for diferente no seu backend
    Set Suite Variable    ${CLIENTE_ID}    ${resposta.json()["newClient"]["_id"]}