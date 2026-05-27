#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru05.rb         *
#*************************************************
class Box
    # constructor method
    def initialize(w,h)
       @width, @height = w, h
    end
    # define to_s method
    def to_s
       "(w:#@width,h:#@height)"  # string formatting of the object.
    end
 end
 
 # create an object
 box = Box.new(10, 20)
 
 # to_s method will be called in reference of string automatically.
 puts "String representation of box is : #{box}"