package main

import "fmt"

// 3 = Troca valores usando XOR

func main() {

	a := 10
	b := 25

	fmt.Println("Antes:")
	fmt.Println("a =", a)
	fmt.Println("b =", b)

	a = a ^ b
	b = a ^ b
	a = a ^ b

	fmt.Println("\nDepois:")
	fmt.Println("a =", a)
	fmt.Println("b =", b)
}