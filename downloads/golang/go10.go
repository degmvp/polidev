package main

import "fmt"

// 10 = Divisão rápida usando shift right

func main() {

	valor := 128

	fmt.Println("Original:", valor)

	fmt.Println("/2 =", valor>>1)
	fmt.Println("/4 =", valor>>2)
	fmt.Println("/8 =", valor>>3)
}