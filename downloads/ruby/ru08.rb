#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru08.rb         *
#*************************************************

# define a class
class Box
    # constructor method
    def initialize(w,h)
       @width, @height = w, h
    end
 
    # accessor methods
    def getWidth
       @width
    end
    def getHeight
       @height
    end
 
    # setter methods
    def setWidth=(value)
       @width = value
    end
    def setHeight=(value)
       @height = value
    end
 end
 
 # create an object
 box = Box.new(10, 20)
 
 # let us freeze this object
 box.freeze
 if( box.frozen? )
    puts "Box object is frozen object"
 else
    puts "Box object is normal object"
 end
 
 # now try using setter methods
 box.setWidth = 30
 box.setHeight = 50
 
 # use accessor methods
 x = box.getWidth()
 y = box.getHeight()
 
 puts "Width of the box is : #{x}"
 puts "Height of the box is : #{y}"