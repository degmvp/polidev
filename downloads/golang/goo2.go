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