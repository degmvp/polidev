#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru12.rb         *
#*************************************************

class Cliente
    def initialize(id, name, msg)
       @cust_id = id
       @cust_name = name
       @cust_addr = msg
    end
    def display_details()
       puts "Cliente id #@cust_id"
       puts "Cliente name #@cust_name"
       puts "Cliente msg  #@cust_addr"
    end
 end
 
 # Create Objects
 cust1 = Cliente.new("1", "John", "Instance variables begin with @")
 cust2 = Cliente.new("2", "Poul", "Instance variables begin with @")
 
 # Call Methods
 cust1.display_details()
 cust2.display_details()