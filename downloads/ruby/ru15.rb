#*************************************************
# Curso de Ruby On Rails Jpessoa 2021/09/29      *
# Programador : Degmar Barbosa - Autodidata      *
#*************************************************
#           Many statements :  ru15.rb         *
#*************************************************

# Ruby - Ranges
# Ranges as Sequences
", "   # Array value separator
range1 = (1..10).to_a
range2 = ('a'..'k').to_a

puts "#{range1}"
puts "#{range2}"

# Assume a range
digits = 0..9

puts digits.include?(5)
ret = digits.min
puts "Min value is #{ret}"

ret = digits.max
puts "Max value is #{ret}"

ret = digits.reject {|i| i < 5 }
puts "Rejected values are #{ret}"

digits.each do |digit|
       puts "In Loop #{digit}"
end
puts 'Digite o num do mes: '
     mes = 3

    result = case mes
    when 1..1 then "jan"
    when 2..2 then "fev"
    when 3..3 then "mar"
    when 4..4 then "abr"
    else "Invalid mes"
 end

puts result