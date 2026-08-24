// wx-go-017-wxgo.go
//
// Título:    Validação de dados: e-mail, URL, CPF e tamanhos
// Descrição: Conjunto de validadores para entrada de usuários e payloads de
//            API: e-mail (via net/mail), URL absoluta (scheme + host), CPF
//            brasileiro com validação dos dígitos verificadores e limites de
//            tamanho de strings. Ajuda a garantir consistência antes de
//            persistir dados.
//
// Exemplo:
//   if !IsValidEmail("ana@exemplo.com") { ... }
//   if !IsValidCPF("529.982.247-25") { ... }
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"net/mail"
	"net/url"
	"regexp"
	"strings"
)

var cpfRegex = regexp.MustCompile(`^\d{11}$`)

// IsValidEmail valida o formato de um endereço de e-mail.
func IsValidEmail(s string) bool {
	_, err := mail.ParseAddress(s)
	return err == nil
}

// IsValidURL verifica se s é uma URL absoluta com scheme e host.
func IsValidURL(s string) bool {
	u, err := url.ParseRequestURI(s)
	return err == nil && u.Scheme != "" && u.Host != ""
}

// IsValidCPF valida os dígitos verificadores de um CPF brasileiro.
func IsValidCPF(cpf string) bool {
	cpf = strings.ReplaceAll(strings.ReplaceAll(cpf, ".", ""), "-", "")
	if !cpfRegex.MatchString(cpf) {
		return false
	}
	if cpf == strings.Repeat(string(cpf[0]), 11) { // todos dígitos iguais
		return false
	}
	digits := []byte(cpf)
	calc := func(length int) int {
		sum := 0
		for i := 0; i < length; i++ {
			sum += int(digits[i]-'0') * (length + 1 - i)
		}
		rest := (sum * 10) % 11
		if rest == 10 {
			rest = 0
		}
		return rest
	}
	return calc(9) == int(digits[9]-'0') && calc(10) == int(digits[10]-'0')
}

// LenRange valida se o tamanho (em runes) está entre min e max.
func LenRange(s string, min, max int) bool {
	n := len([]rune(s))
	return n >= min && n <= max
}

func main() {
	fmt.Println("email válido:", IsValidEmail("ana@exemplo.com"))
	fmt.Println("url válida:", IsValidURL("https://api.exemplo.com/v1"))
	fmt.Println("cpf válido (529.982.247-25):", IsValidCPF("529.982.247-25"))
	fmt.Println("cpf inválido (12345678900):", IsValidCPF("12345678900"))
	fmt.Println("tamanho 5..10 ('golang'):", LenRange("golang", 5, 10))
}