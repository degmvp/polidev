package main

import (
	"encoding/csv"
	"fmt"
	"os"
)

// 12 = Ler arquivo CSV

func main() {

	arquivo, err := os.Open("dados.csv")

	if err != nil {
		fmt.Println("Erro ao abrir CSV:", err)
		return
	}

	defer arquivo.Close()

	leitor := csv.NewReader(arquivo)

	registros, err := leitor.ReadAll()

	if err != nil {
		fmt.Println("Erro ao ler CSV:", err)
		return
	}

	fmt.Println("Conteúdo do arquivo CSV:")

	for i, linha := range registros {
		fmt.Println("Linha", i+1, ":", linha)
	}
}