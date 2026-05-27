#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/30      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru16.rb         *
#*************************************************
# Super class Computador
class Computador
    attr_reader :marca
    def initialize(marca)
        @marca = marca
    end
    def aviso
        puts 'class mae ou super class - aqui!'
    end
end
# Servidor herança da class Computador
class Servidor < Computador
    attr_reader :tipo

    def initialize(marca,tipo)
        super(marca)
        @tipo = tipo
    end
    def aviso
        puts 'sobrescrevendo o metodo aviso - Polimorfismo'
    end
end

# Servidor herança da class Computador
class Cpu < Computador
    attr_reader :tipo

    def initialize(marca,tipo)
        super(marca)
        @tipo = tipo
    end
desk = Servidor.new('IBM', 'SRVprod')
puts desk.marca
puts desk.tipo
desk.aviso
puts '----------------------'
pc = Cpu.new('DDR4', 'Asus')
puts pc.marca
puts pc.tipo
pc.aviso
end
