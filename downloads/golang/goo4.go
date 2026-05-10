package main

import "fmt"

// 4 = Conta bits ligados

func contarBits(n uint8) int {

	total := 0

	for n > 0 {
		total += int(n & 1)
		n >>= 1
	}

	return total
}

func main() {

	var numero uint8 = 255

	fmt.Printf("Número: %08b\n", numero)

	fmt.Println("Bits ligados:", contarBits(numero))
}