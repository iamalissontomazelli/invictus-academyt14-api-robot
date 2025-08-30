*** Settings ***
Resource        ../../resources/login.resource
Resource        ../../resources/board.resource  

*** Test Cases ***

Cadastrar nova Diretoria 
       Cadastrar Diretoria com Sucesso
 
Cadastrar diretoria com mais de 50 caracteres 
     Diretoria com mais de 50 caracteres 

Diretoria já cadastrada no sistema    
     Diretoria já cadastrada no sistema 

   
Cadastrar diretoria com campo vazio
  Cadastrar diretoria com campo vazio

Atualizar uma Diretoria por id
   Atualizar uma Diretoria por id


Diretoria com caractere não permitido   
     Diretoria com caractere não permitido 




Listar diretorias    
     Listar Diretorias
 Mostrar diretoria por id
    Mostrar diretoria por id

pesquisar Diretoria por id inválido
     pesquisar Diretoria por id inválido    
    

    

    


    