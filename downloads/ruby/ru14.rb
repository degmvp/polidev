#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru14.rb         *
#*************************************************

class Varconst
    VAR1 = 100
    VAR2 = 200
    def show
       puts "Constants begin with an uppercase letter VAR1 #{VAR1}"
       puts "Local variable begin with @"
       puts "Constants begin with an uppercase letter VAR2 #{VAR2}"
       puts "Local variable begin with @"
    end
    def showV
       puts 'Ruby Pseudo-Variables like constants :'
       puts 'Self - true - false - __FILE__ - __LINE__ '
       puts __FILE__ 
       puts __LINE__
       puts "Seconds in a day : #{24*60*60}"
       puts "Hours   in a day : #{86400/60/60}"
       puts "Minutes in a day : #{86400/60}"
    end
 end
 
 # Create Objects
 object = Varconst.new()
 object.show
 object.showV