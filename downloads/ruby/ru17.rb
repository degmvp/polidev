#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/30      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru17.rb         *
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
class Cpu < Computador
    attr_reader :tipo

    def initialize(marca,tipo)
        super(marca)
        @tipo = tipo
    end
    def aviso
        puts 'class filha Cpu- Polimorfismo'
    end
end
pc = Cpu.new('DDR4', 'Asus')
puts pc.marca
puts pc.tipo
pc.aviso

# Servidor herança da class Computador
class Ssd < Computador
    attr_reader :tipo

    def initialize(marca,tipo)
        super(marca)
        @tipo = tipo
    end
puts '----------------------'
dsk = Ssd.new('SSD240GB', 'Toshiba')
puts dsk.marca
puts dsk.tipo
dsk.aviso
end