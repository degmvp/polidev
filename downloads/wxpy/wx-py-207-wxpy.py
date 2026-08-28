print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ advR012
# ✅ Python 3.6 alterado: 2017/11/15
# ✅ Objetivo:agenda em arquivo txt
# ✅ Funções :lower(),enumerate(),strip()
#-------------------------------------------------------''')
print('✅' * 50)
global lista, lst_atual
agenda = []
lista = []
lst_atual = []


def p_nome():  # Função para pedir o nome.
    return (input("Nome: "))


def p_telefone():  # Função para pedir o telefone.
    return (input("Telefone: "))


def p_celular():  # Função para pedir o celular.
    return (input("celular: "))


def p_email():  # Função para pedir o email.
    return (input("Email: "))


def listar_dados(nome, telefone, celular, email):  # Função que mostra todos os dados do contato.
    print("Nome: %s\nTelefone: %s\nCelular: %s\nEmail: %s" % (nome, telefone, celular, email))


def pesquisa(nome):  # Função para pesquisar contatos.
    name = nome.lower()  # Convertendo todas as letras em minúsculas.
    for d, e in enumerate(agenda):  # Executando o loop.
        if e[0].lower() == name:  # Determinando uma condição.
            return d  # Executa caso a condição for verdadeira.
    return None  # Executa caso a condição for falsa.


"""
* Foi atribuído o metodo lower para que não haja problemas
quando usuário digitar maiusculo e programa não reconhecer.
* Está usando a função enumerate para acessar a posição do elemento
e o próprio elemento.
* Função return para indicar o valor a retornar.
* Função return None,caso o dado não seja encontrado, não vai retornar nada.
"""


def gera_txt():
    cpx = open('grava_arq.txt', 'w')
    cpy = ''.join(agenda)
    cpx.write(cpy)
    cpx.close()


def consulta():
    global lista, lst_atual, cpy
    arquivo = open('grava_arq.txt', 'r')
    lista = [linha.strip() for linha in arquivo]
    print('nome-----telefone-----celular-----email-------')
    print(lista)
    arquivo.close()


def novo():  # Função para adicionar novo Contato.
    global agenda, cpy  # Definindo variável como Global.
    nome = p_nome()  # Entrada de dados.
    telefone = p_telefone()  # Entrada de dados.
    celular = p_celular()  # Entrada de dados.
    email = p_email()  # Entrada de dados.
    agenda.append(nome + ',' + telefone + ',' + celular + ',' + email)  # Adicionando os dados na agenda
    print(agenda)
    cpy = ''.join(agenda)
    cp = open('grava_arq.txt', 'a')
    cp.write('\n')
    cp.write(cpy)
    cp.close()
    limpa()


"""
* Está sendo utilizada a variável global pois será possível o acesso
da mesma tanto dentro como fora da função, ou seja, pode ser acessada
por todas as funções do programa.
* Está sendo utilizado o método append para ser possível adicionar
novos dados durante a execução do programa na nossa agenda.
"""


def limpa():
    del agenda[0]
    print("Limpa o arrays agenda")


def lstvet():
    print(lista)
    i = 0
    print("\nAgenda\n\n------")
    for e in lista:
        print(i)
        i += 1
        print("Nome: \nTelefone: \nCelular: \nEmail: %s" % (e))
    print("------\n")


def apagar():  # Função para apagar um contato.
    arquivo = open('grava_arq.txt', 'r')
    lista = [linha.strip() for linha in arquivo]
    arquivo.close()

    p = int(input('Digite o indice do array:'))
    if p != -1:
        del lista[p]
        print('deletou', p)
        gera_txt()

        for k in lista:
            x1 = lista[0]
            xx = str(lista).strip(x1)
            cpx = open('copyarq.txt', 'w')
            cpx.write(xx)
            cpx.write('\n')

            x1 = lista[1]
            xx = str(lista).strip(x1)
            cpx = open('copyarq.txt', 'w')
            cpx.write(xx)
            cpx.write('\n')
            cpx.close()

        print(lista)
        i = 0
        print("\nAgenda\n\n------")
        for e in lista:
            print(i)
            i += 1
            print("Nome: \nTelefone: \nCelular: \nEmail: %s" % (e))
            print("------\n")
    else:
        print("Indice não encontrado.")  # Executa caso a condição for falsa.


def editar():  # Função para editar um contato.
    p = pesquisa(p_nome())  # Entrada de dados.
    if p != None:  # Determinando uma condição, caso seja verdadeira:
        nome = agenda[p][0]  # Procurando os dados na agenda.
        telefone = agenda[p][1]  # Procurando os dados na agenda.
        celular = agenda[p][2]  # Procurando os dados na agenda.
        email = agenda[p][3]  # Procurando os dados na agenda.
        print("Encontrado:")  # Exibi informação na tela.
        listar_dados(nome, telefone, celular, email)  # Mostra os dados.
        nome = p_nome()  # Entrada dos novos dados editados.
        telefone = p_telefone()  # Entrada dos novos dados editados.
        celular = p_celular()  # Entrada dos novos dados editados.
        email = p_email()  # Entrada dos novos dados editados.
        agenda[p] = [nome, telefone, celular, email]  # Armazenando os novos dados.
    else:
        print("Nome não encontrado.")  # Executa caso a condição seja falsa.


def listar():
    arquivo = open('grava_arq.txt', 'r')
    lista = [linha.strip() for linha in arquivo]
    print(lista)
    i = 0
    print("\nAgenda\n\n------")
    for e in lista:
        print(i)
        i += 1
        print("Nome: \nTelefone: \nCelular: \nEmail: %s" % (e))
    print("------\n")


def pesquisar():  # Função para Pesquisar os contatos.
    p = pesquisa(p_nome())  # Entrada de dados.
    if p != None:  # Determinando uma condição, caso seja verdadeira:
        nome = agenda[p][0]  # Procurando os dados na agenda.
        telefone = agenda[p][1]  # Procurando os dados na agenda.
        celular = agenda[p][2]  # Procurando os dados na agenda.
        email = agenda[p][3]  # Procurando os dados na agenda.
        print("Encontrado:")  # Exibi informação na tela.
        listar_dados(nome, telefone, celular, email)  # Mostra os dados.
    else:
        print("Nome não encontrado.")  # Executa caso a condição seja falsa.


def validar(pergunta, inicio, fim):  # Função para validar numeros inteiros.
    while True:  # Criando um loop infinito.
        try:  # Criando um acordo/condição.
            valor = int(input(pergunta))  # Entrada de dados.
            if inicio <= valor <= fim:  # Deterimando uma condição.
                return (valor)  # Executa caso for verdadeira.
            return
        except ValueError:  # Executa caso for falsa.
            print("Valor inválido, favor digitar entre %d e %d" % (inicio, fim))


"""
Estamos usando a instrução Try-except, para tratar de um erro anormal,
inesperado que possa ocorrer durante a execução do programa.
Caso o usuário digite um dado diferente do tipo inteiro...
Vai gerar um erro de valor (ValueError) e irá fazer com que nosso
programa pare de funcionar e mostre uma mensagem de erro na tela.
Com isso, utilizamos essa instrução para criar nossa própria mensagem
de erro, e assim podemos também evitar a parada do nosso programa.
"""


def menu():  # Função que exibe o menu de opções.
    print("""
   0 - Gera arquivo (grava_arq.txt)
   1 - Adicionar novo contato
   2 - Editar um contato
   3 - Carrega,Transforma e Imprime (txt para array)
   4 - Lista de contatos
   5 - Apagar um contato
   6 - Imprime vetor atual
   8 - Encerra

""")

    return validar("Escolha uma opção: ", 1, 8)  # Retorna o valor da opção desejada.


while True:  # Criando um loop infinito.
    opção = menu()
    if opção == 8:  # ok
        break
    elif opção == 0:  # ok
        gera_txt()
    elif opção == 1:  # ok
        novo()
    elif opção == 2:
        editar()
    elif opção == 3:  # ok
        consulta()
    elif opção == 4:  # ok
        listar()
    elif opção == 5:
        apagar()
    elif opção == 6:  # ok
        lstvet()
