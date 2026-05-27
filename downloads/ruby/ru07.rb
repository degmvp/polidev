#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru07.rb         *
#*************************************************
# define a class
class Box
    # constructor method
    def initialize(w,h)
       @width, @height = w, h
    end
    # instance method
    def getArea
       @width * @height
    end
 end
 
 # define a subclass
 class BigBox < Box
 
    # change existing getArea method as follows
    def getArea
       @area = @width * @height
       puts "Big box area is : #{@area}"
    end
 end
 
 # create an object
 box = BigBox.new(20, 30)
 
 # print the area using overriden method.
 box.getArea()