// wx-go-010-wxgo.go
//
// Título:    Gerador de UUID v4 seguro
// Descrição: Gera identificadores únicos universais (UUID) versão 4 usando
//            crypto/rand (fonte criptograficamente segura), seguindo o padrão
//            RFC 4122 (bits de versão e variante). Serve como chave primária,
//            idempotência de requisições e rastreamento em logs distribuídos.
//
// Exemplo:
//   id, err := NewUUIDv4()
//   // exemplo: "f47ac10b-58cc-4372-a567-0e02b2c3d479"
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"crypto/rand"
	"fmt"
)

// NewUUIDv4 gera um UUID versão 4 aleatório no formato 8-4-4-4-12.
func NewUUIDv4() (string, error) {
	var b [16]byte
	if _, err := rand.Read(b[:]); err != nil {
		return "", err
	}
	b[6] = (b[6] & 0x0f) | 0x40 // define a versão 4
	b[8] = (b[8] & 0x3f) | 0x80 // define a variante RFC 4122
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}

func main() {
	for i := 0; i < 3; i++ {
		id, err := NewUUIDv4()
		if err != nil {
			panic(err)
		}
		fmt.Println("UUID:", id)
	}
}