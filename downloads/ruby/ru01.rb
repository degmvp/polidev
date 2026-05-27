#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/27      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru01.rb         *
#*************************************************
# define a class
class Box
   # constructor method
   def initialize(w,h)
      @width, @height = w, h
   end

   # accessor methods
   def printWidth
      @width
   end

   def printHeight
      @height
   end
end
# create an object
box = Box.new(100, 200)

# use accessor methods
x = box.printWidth()
y = box.printHeight()

puts "Width of the box is : #{x}"
puts "Height of the box is : #{y}"