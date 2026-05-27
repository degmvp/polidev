#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru04.rb         *
#*************************************************
#class Box
class Box
    # Initialize our class variables
    @@count = 0
    def initialize(w,h)
       # assign instance avriables
       @width, @height = w, h
 
       @@count += 1
    end
 
    def self.printCount()
       puts "Box count is : #@@count"
    end
 end
 
 # create two object
 box1 = Box.new(10, 20)
 box2 = Box.new(30, 100)
 
 # call class method to print box count
 Box.printCount()