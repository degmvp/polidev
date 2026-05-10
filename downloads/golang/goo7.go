package main

import "fmt"

// 7 = Alterna bit usando XOR

func main() {

	var numero uint8 = 8

	fmt.Printf("Antes : %08b\n", numero)

	numero ^= (1 << 3)

	fmt.Printf("Depois: %08b\n", numero)
}