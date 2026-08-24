// wx-go-011-wxgo.go
//
// Título:    Hash e verificação de senha com salt
// Descrição: HashPassword gera um hash derivado da senha com salt aleatório de
//            16 bytes e múltiplas iterações de SHA-256, armazenado no formato
//            "salt:hash". VerifyPassword compara a senha informada com o hash
//            em tempo constante (crypto/subtle), evitando ataques de timing.
//            Observação: para produção, prefira bcrypt/argon2 (dependência
//            externa); este exemplo é autocontido e educacional.
//
// Exemplo:
//   hash, _ := HashPassword("minha-senha")
//   ok := VerifyPassword("minha-senha", hash) // true
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"fmt"
	"strings"
)

const (
	saltSize   = 16
	iterations = 100_000
)

// deriveKey aplica iterações de SHA-256 sobre salt+senha.
func deriveKey(password string, salt []byte) []byte {
	sum := append(append([]byte{}, salt...), []byte(password)...)
	for i := 0; i < iterations; i++ {
		h := sha256.Sum256(sum)
		sum = h[:]
	}
	return sum
}

// HashPassword gera o hash armazenável "salt:hash" para uma senha.
func HashPassword(password string) (string, error) {
	salt := make([]byte, saltSize)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	hash := deriveKey(password, salt)
	return fmt.Sprintf("%s:%s", hex.EncodeToString(salt), hex.EncodeToString(hash)), nil
}

// VerifyPassword valida a senha contra o hash armazenado em tempo constante.
func VerifyPassword(password, stored string) bool {
	parts := strings.SplitN(stored, ":", 2)
	if len(parts) != 2 {
		return false
	}
	salt, err := hex.DecodeString(parts[0])
	if err != nil {
		return false
	}
	want, err := hex.DecodeString(parts[1])
	if err != nil {
		return false
	}
	got := deriveKey(password, salt)
	return subtle.ConstantTimeCompare(got, want) == 1
}

func main() {
	hash, err := HashPassword("senha-super-secreta")
	if err != nil {
		panic(err)
	}
	fmt.Println("hash armazenado:", hash)
	fmt.Println("verificação correta:", VerifyPassword("senha-super-secreta", hash))
	fmt.Println("verificação errada:", VerifyPassword("senha-errada", hash))
}