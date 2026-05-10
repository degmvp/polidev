package main

import "fmt"

// 14 = Converter valores decimais em binários

func main() {

	numeros := []int{1, 2, 3, 7, 8, 10, 15, 16, 31, 32, 64, 128, 255}

	fmt.Println("Decimal para Binário")
	fmt.Println("--------------------")

	for _, n := range numeros {
		fmt.Printf("Decimal: %3d  Binário: %08b\n", n, n)
	}
}