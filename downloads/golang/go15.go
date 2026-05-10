package main

import "fmt"

// 15 = Converter valores decimais em hexadecimais

func main() {

	numeros := []int{10, 15, 16, 31, 32, 64, 127, 128, 255, 256, 512, 1024}

	fmt.Println("Decimal para Hexadecimal")
	fmt.Println("------------------------")

	for _, n := range numeros {
		fmt.Printf("Decimal: %4d  Hexadecimal: 0x%X\n", n, n)
	}
}