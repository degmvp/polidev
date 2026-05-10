package main

import "fmt"

// 5 = Liga um bit específico

func main() {

	var flags uint8 = 0

	fmt.Printf("Inicial: %08b\n", flags)

	flags |= (1 << 2)

	fmt.Printf("Bit 2 ligado: %08b\n", flags)
}