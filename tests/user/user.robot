*** Settings ***
Resource        ../../resources/login.resource
Resource        ../../resources/user.resource
Library        RequestsLibrary
Library        String
Library        Collections

*** Test Cases ***
Cadastro de novo Usuário
    Cadastrar novo usuario
    
Login com User
    Login com Usuário
Listagem de Usuário
    Listagem de Usuário

Contagem de Usuário
    Contagem de Usuário

Buscar Usuário
    Mostrar Usuário

Deletando Usuário
    Deletar os dados do usuário

Atualizar senha do Usuário
    Atualizar senha do usuário

Atualizar status do Usuário
    Atualizar status do usuário