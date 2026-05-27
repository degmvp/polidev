#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/30      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru18.rb         *
#*************************************************

class Livro
    attr_reader :nome, :ano, :preco

    def initialize(nome, ano, preco)
        @nome = nome
        @ano  = ano
        @preco = preco
    end
    def show_dados
        puts "Livro: #{@nome}, data: #{@ano}, Preco: #{@preco}"
    end
    def desconto
        if @ano <= 1999
            @preco = @preco * 0.9
        else
            @preco
        end
    end 
end
L1 = Livro.new('A biblia', 1999, 50.00)
L1.desconto
L1.show_dados

