package main

import "fmt"

// 9 = Multiplicação rápida usando shift left

func main() {

	valor := 7

	fmt.Println("Original:", valor)

	fmt.Println("x2 =", valor<<1)
	fmt.Println("x4 =", valor<<2)
	fmt.Println("x8 =", valor<<3)
}