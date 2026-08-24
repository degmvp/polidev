// wx-go-007-wxgo.go
//
// Título:    JSON seguro + deep copy via JSON
// Descrição: SafeMarshal serializa qualquer valor para JSON devolvendo um erro
//            claro (e sem escapar HTML por padrão, útil para APIs).
//            DeepCopy clona estruturas de forma profunda usando JSON,
//            garantindo que a cópia não compartilhe slices/maps com o original.
//
// Exemplo:
//   b, err := SafeMarshal(obj)
//   copia, err := DeepCopy(obj)
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
)

// SafeMarshal serializa v em JSON sem escapar HTML e com erro contextualizado.
func SafeMarshal(v any) ([]byte, error) {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	if err := enc.Encode(v); err != nil {
		return nil, fmt.Errorf("json marshal: %w", err)
	}
	return bytes.TrimSpace(buf.Bytes()), nil
}

// DeepCopy clona src em um novo valor independente, via serialização JSON.
func DeepCopy[T any](src T) (T, error) {
	var dst T
	data, err := json.Marshal(src)
	if err != nil {
		return dst, fmt.Errorf("deep copy marshal: %w", err)
	}
	if err := json.Unmarshal(data, &dst); err != nil {
		return dst, fmt.Errorf("deep copy unmarshal: %w", err)
	}
	return dst, nil
}

func main() {
	type Usuario struct {
		Nome string   `json:"nome"`
		Tags []string `json:"tags"`
	}

	u := Usuario{Nome: "Ana", Tags: []string{"go", "api"}}
	b, err := SafeMarshal(u)
	if err != nil {
		panic(err)
	}
	fmt.Println("json:", string(b))

	clone, err := DeepCopy(u)
	if err != nil {
		panic(err)
	}
	clone.Tags[0] = "mutado"
	fmt.Println("original intacto:", u.Tags)
	fmt.Println("cópia independente:", clone.Tags)
}