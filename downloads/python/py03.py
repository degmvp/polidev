print('✅' * 50) 
vet = input('Digite header:') 
print('--------->---------------------------<---------') 
print('-------------------->Class---------------------') 
print('--------->---------------------------<---------') 
print(vet) 
print('self --> é uma variavel de classe') 
print('passa toda -->class<-- para dentro da definição') 
print('-' * 65) 
print('><' * 32) 
print('Deg - Python 3.66 - em 2018/07/29 ') 
print('Programa - class_01 - Python 3.66 ') 
print('><' * 32) 
print('--------->---------------------------<---------') 
print('-------------------->Class---------------------') 
print('--------->---------------------------<---------') 

class Pessoa: 
    def __init__(self): 
        self.listaDePessoas = [] 

    def cadastrar_pessoa(self,nome): 
        self.listaDePessoas.append(nome) 
        print('Pessoa adiionada com sucesso!') 

    def __iter__(self): 
        return iter(self.listaDePessoas) 

    def  __len__(self): 
        return len(self.listaDePessoas) 

vinst = Pessoa() 
vinst.cadastrar_pessoa('Degmar') 
vinst.cadastrar_pessoa('Janaina') 
vinst.cadastrar_pessoa('Laura') 
vinst.cadastrar_pessoa('Lawrence') 

for x in vinst: 
    print(x)