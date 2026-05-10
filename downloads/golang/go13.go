package main

import (
	"fmt"
	"os"
)

// 13 = Ler arquivo TXT

func main() {

	conteudo, err := os.ReadFile("texto.txt")

	if err != nil {
		fmt.Println("Erro ao ler TXT:", err)
		return
	}

	fmt.Println("Conteúdo do arquivo TXT:")
	fmt.Println(string(conteudo))
}