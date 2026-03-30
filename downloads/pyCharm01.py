# Criar uma lista de pessoas
# Cadastrar uma nova pessoa
# Listar todas as pessoas dentro dessa lista
# Obter a quantidade de pessoas que existe dentro desta lista

#-------------------------------------------------------''')
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
print('--------->---------------------------<---------')
print('--------->Class Metodo Construtor--------------')
print('--------->---------------------------<---------')

class Many_obj():
    def __init__(self):
        self.descreve = 'Metodo construtor do objeto'
        self.programa = 'Usando variaveis de class'
        print('Metodo construtor chamado com sucesso!')

    def imprime(self):
        print('Many_obj é:%s \nO programa é: %s'%(self.descreve,self.programa))

obj_instanciado = Many_obj()
obj_instanciado.imprime()

print('✅' * 50)

print('--------->---------------------------<---------')
print('-------------------->Class---------------------')
print('--------->---------------------------<---------')
print(vet)
print('--------->---------------------------<---------')
print('-------------------->Herança-------------------')
print('--------->---------------------------<---------')


class Cab:
    cab1 = 'Programação orientada ao objeto (Class)'
    ano = 2021
    __nome = 'Herança'

    def criarcab(self, __nome, ano, cab1):
        self.__nome = nome
        self.ano = ano
        self.cab1 = cab1

    def obternome(self):
        return self.__nome

    def obterano(self):
        return self.ano

    def obtercab1(self):
        return self.cab1


hd = Cab()
print(hd.obtercab1())
print(hd.obternome())
print(hd.obterano())


class ClassePai:
    var1 = 'definição de classe pai'


class ClasseFilha(ClassePai):
    pass


objeto_pai = ClassePai()
objeto_filho = ClasseFilha()

print(objeto_pai.var1)
print(objeto_filho.var1, 'ClasseFilha foi herdado de ClassePai')

print('✅' * 50)
print('Para passar toda -->class<-- para dentro da definição usamos **self**')
print('O parametro que passamos para a definição é a propria class no caso as variaveis')
print('self.variavel é uma variavel de classe, outra é variavel local')


class Entrevista():
    nome = ''
    ano_informado = 0
    idade = 0

    def pergunta_nome(self):
        self.nome = input('Qual é o seu nome? ')
        print('O seu nome é ', self.nome)
        return self.nome

    def pergunta_idade(self, ano_atual=2021):
        self.ano_informado = int(input('Então ' + self.nome + ', em que ano vc nasceu?'))
        self.idade = ano_atual - self.ano_informado

        print('Voce tem', self.idade, 'anos')
        return (self.ano_informado, self.idade)  # tuple


obj_inst = Entrevista()
obj_inst.pergunta_nome()
obj_inst.pergunta_idade()

print('><' * 32)
print('--------->---------------------------<---------')
print('--------->Class Metodo Construtor--------------')
print('--------->---------------------------<---------')
class Too_obj():
    def __init__(self, p1,p2):
        self.descreve = p1
        self.programa = p2
        print('Metodo construtor chamado com sucesso!')

    def imprime(self):
        print('O obj é:%s \nO programa é: %d'%(self.descreve,self.programa))

obj_instanciado = Too_obj('Metodo construtor do objeto',2)
obj_instanciado.imprime()

class Moo_obj():
    def __init__(self,p1,p2):
        self.nome = input('Digite nome:')
        self.cel  = input('Celular:')
        print('Metodo construtor chamado com sucesso!')

    def imprime(self):
        print('O Moo_obj é:%s \nO celular é: %s'%(self.nome,self.cel))


obj_inst = Moo_obj('','')
obj_inst.imprime()

