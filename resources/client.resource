*** Settings ***
Documentation        Resource da sessão Client (schema do Swagger /client)
Library              RequestsLibrary
Library              SeleniumLibrary
Library              String
Library              Collections
Resource             login.resource      # importa Login com sysadmin e ${baseURL}

*** Keywords ***

# ---------------- Helpers de documentos --------------------


Gerar CPF Válido
    [Documentation]    Gera CPF válido (11 dígitos com DV) como string.
    # 1) 9 dígitos iniciais aleatórios
    ${n}=         Evaluate    [random.randint(0,9) for _ in range(9)]    modules=random
    ${ns}=        Create Dictionary    n=${n}    # namespace p/ usar 'n' no Evaluate

    # 2) 1º dígito verificador (d1)
    ${d1}=        Evaluate    (sum([(10-i)*n[i] for i in range(9)])*10) % 11    modules=random    namespace=${ns}
    ${d1}=        Set Variable If    ${d1} == 10    0    ${d1}
    Append To List    ${n}    ${d1}
    Set To Dictionary  ${ns}   n=${n}

    # 3) 2º dígito verificador (d2)
    ${d2}=        Evaluate    (sum([(11-i)*n[i] for i in range(10)])*10) % 11    modules=random    namespace=${ns}
    ${d2}=        Set Variable If    ${d2} == 10    0    ${d2}
    Append To List    ${n}    ${d2}

    # 4) Concatena tudo em uma string (ex.: "12345678909")
    ${ns}=        Create Dictionary    n=${n}
    ${cpf}=       Evaluate    ''.join(map(str, n))    namespace=${ns}
    RETURN        ${cpf}

Gerar RG Aleatorio
    [Documentation]    Gera RG simples com 7 dígitos.
    ${rg}=    Generate Random String    length=7    chars=[NUMBERS]
    RETURN     ${rg}

# ---------------- Helpers principais -----------------------


Criar Cliente - Dados Válidos
    [Documentation]    Prepara dados válidos conforme o Swagger (fullName, birthDate, mail, phone, currentRole, documents[], address[]).

    # Aleatórios para evitar duplicidade entre execuções
    ${rlet}=          Generate Random String    length=6    chars=[LETTERS]
    ${rlet}=          Convert To Lower Case     ${rlet}
    ${rnum}=          Generate Random String    length=9    chars=[NUMBERS]

    # Campos básicos
    Set Test Variable    ${FULL_NAME}       Cliente ${rlet}
    Set Test Variable    ${BIRTH_DATE}      24082023          # somente dígitos (formato aceito pelo backend)
    Set Test Variable    ${MAIL}            ${rlet}.qa@invictus.com
    Set Test Variable    ${PHONE}           5591${rnum}       # numérico
    Set Test Variable    ${CURRENT_ROLE}    ADMIN

    # Documents (CPF válido + RG aleatório) — array com 1 objeto
    ${CPF}=             Gerar CPF Válido
    ${RG}=              Gerar RG Aleatorio
    ${doc}=             Create Dictionary    rg=${RG}    cpf=${CPF}
    ${DOCS_LIST}=       Create List          ${doc}
    Set Test Variable   ${DOCS_LIST}         ${DOCS_LIST}

    # Address (array com 1 objeto) — 'number' deve ser numérico (int), não string
    ${NUMERO_STR}=      Generate Random String    length=3    chars=[NUMBERS]
    ${NUMERO}=          Convert To Integer       ${NUMERO_STR}     # garante inteiro no JSON
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


# ---------------- Sessão com autenticação ------------------


Criar Sessão Autenticada Client
    [Documentation]    Realiza login e cria a sessão com Authorization para chamadas autenticadas.
    ${TOKEN}=          Login com sysadmin
    ${headers}=        Create Dictionary
    ...                accept=application/json
    ...                Content-Type=application/json
    ...                Authorization=${TOKEN}
    Create Session     alias=develop        url=${baseURL}    headers=${headers}    verify=true

# ---------------- Montagem do body -------------------------


Montar Body Cliente (Valido)
    [Documentation]    Monta o JSON exatamente como no Example do Swagger.
    ${body}=     Create Dictionary
    ...          fullName=${FULL_NAME}
    ...          birthDate=${BIRTH_DATE}
    ...          mail=${MAIL}
    ...          phone=${PHONE}
    ...          currentRole=${CURRENT_ROLE}
    ...          documents=${DOCS_LIST}
    ...          address=${ADDR_LIST}
    RETURN       ${body}

# ---------------- POST (criar) ------------------------------


Cadastrar Cliente com Sucesso
    [Documentation]    POST /client com body válido → espera 201 e guarda o _id para uso posterior.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)

    Log    BODY /client: ${body}
    ${resposta}=    POST On Session    alias=develop    url=/client    json=${body}    expected_status=201
    Log    RESP /client: ${resposta.json()}

    # Ajuste o caminho do ID se sua API retornar diferente
    Set Suite Variable    ${CLIENTE_ID}    ${resposta.json()["newClient"]["_id"]}


# ---------------- NEGATIVOS (validação) --------------------
    

Cliente com Email Inválido
    [Documentation]    Envia e-mail inválido (mantém o resto válido) → espera 400.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)
    Set To Dictionary    ${body}    mail=usuario@@dominio
    Run Keyword And Expect Error    HTTPError: 400*    POST On Session    alias=develop    url=/client    json=${body}

Cliente com Telefone Inválido
    [Documentation]    Envia phone com máscara/letras (mantém o resto válido) → espera 400.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)
    Set To Dictionary    ${body}    phone=(11) 99999-9999
    Run Keyword And Expect Error    HTTPError: 400*    POST On Session    alias=develop    url=/client    json=${body}

# ---------------- GET (listar/buscar) ----------------------


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

Buscar Cliente por Id Inválido (400/404)
    [Documentation]    GET /client/{id inválido} → espera 400 ou 404
    ${id_invalido}=    Set Variable    660340e40&17ca8b3bf6107d8
    Run Keyword And Expect Error    HTTPError: 4*    GET On Session    alias=develop    url=/client/${id_invalido}


# Validando numero de cliente


#Status 200
Cliente Id Válido Deve Retornar 200
    [Documentation]    Cria cliente, pega ${CLIENTE_ID} e valida GET /client/{id} = 200.
    # Pré-condição: criar e capturar ID
    Cadastrar Cliente com Sucesso
    Criar Sessão Autenticada Client

    ${resp}=   GET On Session    alias=develop    url=/client/${CLIENTE_ID}
    Status Should Be    200    ${resp}
    Should Be Equal As Strings    ${CLIENTE_ID}    ${resp.json()["client"]["_id"]}


# Status 400
Cliente Id Malformado Deve Reprovar
    [Documentation]    Exercita IDs com tamanho inválido ou não-hex → espera 400.
    Criar Sessão Autenticada Client

    ${ids_invalidos}=    Create List
    ...    12345                         # muito curto
    ...    0123456789abcdef0123456789    # muito longo (26)
    ...    0123456789abcdef012345zz      # não-hex (zz)

    FOR    ${id}    IN    @{ids_invalidos}
        ${res}=    GET On Session    alias=develop    url=/client/${id}
        IF    ${res.status_code} == 400
            Log To Console    ✅ Malformado '${id}' → 400
        ELSE
            Fail    Esperado 400 para ID malformado '${id}', veio ${res.status_code}. Body: ${res.content}
        END
    END

# Status 404

Cliente Id Válido Porem Inexistente Deve Reprovar
    [Documentation]    Usa um 24-hex aleatório (provavelmente não existe) → espera 404.
    Criar Sessão Autenticada Client
    ${id_fake}=    Gerar ObjectId Aleatorio

    ${res}=    GET On Session    alias=develop    url=/client/${id_fake}
    IF    ${res.status_code} == 404
        Log To Console    ✅ Inexistente '${id_fake}' → 404
    ELSE
        Fail    Esperado 404 para ID inexistente, veio ${res.status_code}. Body: ${res.content}
    END




# ---------------- PUT (atualizar) --------------------------

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
    ...               currentRole=USER           # muda role
    ...               documents=${DOCS2}
    ...               address=${ADDR2}

    ${resp}=          PUT On Session    alias=develop    url=/client/${CLIENTE_ID}    json=${body_put}    expected_status=200
    Log               RESP PUT: ${resp.json()}

Atualizar Cliente com Body Inválido (400)
    [Documentation]    PUT /client/{id} com campos inválidos → 400
    Cadastrar Cliente com Sucesso
    ${body}=           Create Dictionary
    ...                fullName=
    ...                birthDate=abc123
    ...                mail=usuario@@dominio
    ...                phone=(11) 99999-9999
    ...                currentRole=123##
    ...                documents=${EMPTY}
    ...                address=${EMPTY}
    Run Keyword And Expect Error    HTTPError: 400*    PUT On Session    alias=develop    url=/client/${CLIENTE_ID}    json=${body}

# ---------------- DELETE (remover) --------------------------

Remover Cliente por Id (Sucesso)
    [Documentation]    DELETE /client/{id} → remove o cliente e valida que não existe mais.
    # 1) Pré-condição: cria cliente e guarda ${CLIENTE_ID}
    Cadastrar Cliente com Sucesso

    # 2) Executa o DELETE aceitando 200 ou 204 (alguns backends variam)
    ${ok200}=    Run Keyword And Return Status
    ...          DELETE On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=200
    Run Keyword If    not ${ok200}
    ...    DELETE On Session    alias=develop    url=/client/${CLIENTE_ID}    expected_status=204

    # 3) Confirma remoção: GET pelo mesmo id deve retornar 404
    Run Keyword And Expect Error    HTTPError: 404*    GET On Session    alias=develop    url=/client/${CLIENTE_ID}


# ---------------- NEGATIVO: cargo não alfabético -----------

Cliente com Cargo Não Alfabético
    [Documentation]    Envia currentRole com números/símbolos (mantém resto válido) → espera 400.
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=        Montar Body Cliente (Valido)
    # quebra apenas o campo de cargo
    Set To Dictionary    ${body}    currentRole=Dev123##
    Run Keyword And Expect Error    HTTPError: 400*    POST On Session    alias=develop    url=/client    json=${body}



# ============================================================
# ------------------- Regras de negócio ---------------------
# ============================================================

Cargo com Valor Alfabético Deve Aprovar
    [Documentation]    Envia currentRole somente com letras → deve aprovar (201).
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=    Montar Body Cliente (Valido)
    Set To Dictionary    ${body}    currentRole=Manager
    ${resp}=    POST On Session    alias=develop    url=/client    json=${body}
    Status Should Be    201    ${resp}
    Log To Console    Cargo alfabético aceito: ${resp.json()}

Cargo com Valor Não Alfabético Deve Reprovar
    [Documentation]    Envia currentRole com números ou símbolos → deve reprovar (400).
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=    Montar Body Cliente (Valido)
    Set To Dictionary    ${body}    currentRole=Gerente123
    Run Keyword And Expect Error    HTTPError: 400*    POST On Session    alias=develop    url=/client    json=${body}




# ============================================================
# --------- RAMO DE ATIVIDADE (apenas alfabético) ------------
# ============================================================

Ramo Alfabético Deve Aprovar
    [Documentation]    POST /client com businessBranch=${valor} (apenas letras/acentos/espaços) → espera 200/201.
    [Arguments]    ${valor}

    # 1) Preparação
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=    Montar Body Cliente (Valido)
    Set To Dictionary    ${body}    businessBranch=${valor}

    # 2) Execução
    ${resp}=    POST On Session    alias=develop    url=/client    json=${body}

    # 3) Status esperado (sem 'Run Keyword Unless')
    IF    ${resp.status_code} in [200, 201]
        Log To Console    ✅ Cliente criado com ramo '${valor}', status ${resp.status_code}
    ELSE
        Fail    Esperado 200/201, veio ${resp.status_code}. Body: ${resp.content}
    END

    # 4) Validação do eco, se existir (sem indexar no IF)
    ${j}=    Set Variable    ${resp.json()}
    IF    'newClient' in ${j}
        ${nc}=        Get From Dictionary    ${j}    newClient
        IF    'businessBranch' in ${nc}
            ${branch}=    Get From Dictionary    ${nc}    businessBranch
            Should Be Equal As Strings    ${branch}    ${valor}
        ELSE
            Log To Console    [AVISO] 'newClient' veio sem 'businessBranch'. JSON: ${j}
        END
    ELSE
        Log To Console    [AVISO] Campo 'newClient' não retornado no corpo. JSON: ${j}
    END

    

Cliente Já Cadastrado no Sistema
    [Documentation]    Cria um cliente e tenta cadastrar novamente com os mesmos dados → espera 409.
    # 1) Login e montar body fixo para o par 1ª/2ª requisição
    Criar Sessão Autenticada Client
    Criar Cliente - Dados Válidos
    ${body}=    Montar Body Cliente (Valido)

    # 2) Primeira criação deve passar (201)
    ${resp1}=    POST On Session    alias=develop    url=/client    json=${body}    expected_status=201
    Log    Primeiro cadastro OK: ${resp1.json()}

    # 3) Segunda criação com o MESMO body deve falhar com 409
    Run Keyword And Expect Error    HTTPError: 409*    POST On Session    alias=develop    url=/client    json=${body}