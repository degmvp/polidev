ge main

import (
	"fmt"
)

// 1 = Verifica número par usando bitwise

func main() {
	var a uint8 = 12 // 00001100
	var b uint8 = 10 // 00001010

	fmt.Println("POLYDEV | Golang Bitwise")
	fmt.Println("Leia • Entenda • Execute seu código")
	fmt.Println()

	fmt.Printf("a = %d | binário: %08b\n", a, a)
	fmt.Printf("b = %d | binário: %08b\n", b, b)

	fmt.Println("\nOperações Bitwise:")

	fmt.Printf("a & b  = %d  | %08b  | AND\n", a&b, a&b)
	fmt.Printf("a | b  = %d  | %08b  | OR\n", a|b, a|b)
	fmt.Printf("a ^ b  = %d  | %08b  | XOR\n", a^b, a^b)
	fmt.Printf("^a     = %d | %08b  | NOT\n", ^a, ^a)

	fmt.Println("\nDeslocamentos:")

	fmt.Printf("a << 1 = %d  | %08b  | desloca 1 bit à esquerda\n", a<<1, a<<1)
	fmt.Printf("a >> 1 = %d   | %08b  | desloca 1 bit à direita\n", a>>1, a>>1)

	fmt.Println("\nTestando bits específicos:")

	var numero uint8 = 42 // 00101010

	fmt.Printf("numero = %d | %08b\n", numero, numero)

	for bit := 0; bit < 8; bit++ {
		mascara := uint8(1 << bit)

		if numero&mascara != 0 {
			fmt.Printf("Bit %d está LIGADO\n", bit)
		} else {
			fmt.Printf("Bit %d está DESLIGADO\n", bit)
		}
	}

	fmt.Println("\nLigando, desligando e alternando bits:")

	var flags uint8 = 0

	fmt.Printf("flags inicial     = %08b\n", flags)

	flags = flags | (1 << 1)
	fmt.Printf("liga bit 1        = %08b\n", flags)

	flags = flags | (1 << 3)
	fmt.Printf("liga bit 3        = %08b\n", flags)

	flags = flags &^ (1 << 1)
	fmt.Printf("desliga bit 1     = %08b\n", flags)

	flags = flags ^ (1 << 3)
	fmt.Printf("alterna bit 3     = %08b\n", flags)
}