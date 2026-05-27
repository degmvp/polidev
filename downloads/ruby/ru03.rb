#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru03.rb         *
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
 
 # create an object
 box = Box.new(10, 20)
 
 # call instance methods
 a = box.getArea()
 puts "Area of the box is : #{a}"