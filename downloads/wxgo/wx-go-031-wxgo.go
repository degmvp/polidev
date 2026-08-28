// wx-go-031-wxgo.go
// Migrado do acervo legado: go11.go
// POLYDEV | WXGO

package main

import "fmt"

// 11 = Extrai bit específico

func main() {

	var numero uint8 = 42

	fmt.Printf("Número: %08b\n", numero)

	bit := 3

	valor := (numero >> bit) & 1

	fmt.Printf("Bit %d = %d\n", bit, valor)
}
