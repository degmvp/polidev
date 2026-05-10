package main

import "fmt"

// 8 = Máscara de permissões usando bitwise

const (
	LER = 1 << iota
	ESCREVER
	EXECUTAR
)

func main() {

	var permissao uint8

	permissao |= LER
	permissao |= EXECUTAR

	fmt.Printf("Permissões: %08b\n", permissao)

	if permissao&LER != 0 {
		fmt.Println("Pode LER")
	}

	if permissao&ESCREVER != 0 {
		fmt.Println("Pode ESCREVER")
	}

	if permissao&EXECUTAR != 0 {
		fmt.Println("Pode EXECUTAR")
	}
}