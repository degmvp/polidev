// wx-go-012-wxgo.go
//
// Título:    Criptografia AES-GCM (encrypt / decrypt autenticado)
// Descrição: Cifra e decifra dados com AES-256-GCM, que além de confidencialidade
//            garante autenticidade e integridade (GCM é um modo autenticado).
//            O nonce aleatório é gerado por tentativa e prefixado ao texto
//            cifrado; o resultado é codificado em base64 para armazenamento.
//            Ideal para campos sensíveis, tokens e dados em repouso.
//
// Exemplo:
//   cifrado, err := EncryptAESGCM(chave32Bytes, []byte("segredo"))
//   texto, err := DecryptAESGCM(chave32Bytes, cifrado)
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"
)

// EncryptAESGCM cifra plaintext com AES-256-GCM. key deve ter 32 bytes.
func EncryptAESGCM(key []byte, plaintext []byte) (string, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}
	sealed := gcm.Seal(nonce, nonce, plaintext, nil)
	return base64.StdEncoding.EncodeToString(sealed), nil
}

// DecryptAESGCM decifra o valor gerado por EncryptAESGCM.
func DecryptAESGCM(key []byte, encoded string) ([]byte, error) {
	data, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return nil, err
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	nonceSize := gcm.NonceSize()
	if len(data) < nonceSize {
		return nil, fmt.Errorf("dados cifrados muito curtos")
	}
	return gcm.Open(nil, data[:nonceSize], data[nonceSize:], nil)
}

func main() {
	key := []byte("0123456789abcdef0123456789abcdef") // 32 bytes = AES-256
	msg := "mensagem confidencial"

	enc, err := EncryptAESGCM(key, []byte(msg))
	if err != nil {
		panic(err)
	}
	fmt.Println("cifrado (base64):", enc)

	dec, err := DecryptAESGCM(key, enc)
	if err != nil {
		fmt.Println("erro ao decifrar:", err)
	} else {
		fmt.Println("decifrado:", string(dec))
	}
}