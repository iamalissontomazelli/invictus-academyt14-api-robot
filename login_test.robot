*** Settings ***
Resource        ../../resources/login.resource
Resource        ../../resources/user.resource


*** Test Cases ***
Logar com Sysadmin
    Login com sysadmin

Validar Token Sysadmin    
    Validar o token sysadmin e gravar autorização 

#Teste Novo usuario
    #Cadastrar novo usuario  
Listar usuario
    Listagem de Usuário  
    

Contagem de usuario  
    Contagem de Usuário  
          