#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru13.rb         *
#*************************************************

class Cliente
    @@no_of_clientes = 0
    def initialize(id, name, msg)
       @cust_id = id
       @cust_name = name
       @cust_addr = msg
    end
    def display_details()
       puts "Cliente id #@cust_id"
       puts "Cliente name #@cust_name"
       puts "Cliente msg #@cust_addr"
    end
    def total_no_of_clientes()
       @@no_of_clientes  += 1
       puts "Total number of clients: #@@no_of_clientes "
       puts '@@ must be initialized before they can be used in method'
    end
 end
 
 # Create Objects
 cust1 = Cliente.new("1", "John", "Class variables begin with @@ ")
 cust2 = Cliente.new("2", "Poul", "Class variables begin with @@ ")
 
 # Call Methods
 cust1.total_no_of_clientes()
 cust2.total_no_of_clientes()