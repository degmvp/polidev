// wx-go-022-wxgo.go
// Migrado do acervo legado: go02.go
// POLYDEV | WXGO

package main

import "fmt"

// 2 = Verifica número par usando bitwise

func main() {
	numero := 37

	if numero&1 == 0 {
		fmt.Println(numero, "é PAR")
	} else {
		fmt.Println(numero, "é ÍMPAR")
	}
}
