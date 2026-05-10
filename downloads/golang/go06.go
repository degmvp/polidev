package main

import "fmt"

// 6 = Desliga um bit

func main() {

	var flags uint8 = 255

	fmt.Printf("Inicial: %08b\n", flags)

	flags &^= (1 << 3)

	fmt.Printf("Bit 3 desligado: %08b\n", flags)
}