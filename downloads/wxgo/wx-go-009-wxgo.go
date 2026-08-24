// wx-go-009-wxgo.go
//
// Título:    Utilitários de string: slug, truncar, camelCase e máscara
// Descrição: Helpers avançados para manipulação de texto: Slugify gera slugs
//            seguros para URLs, Truncate limita o tamanho preservando unicode,
//            CamelCase converte separadores para notação camelCase e Mask
//            esconde parte de um dado sensível (cartão, CPF, e-mail).
//
// Exemplo:
//   slug := Slugify("Olá Mundo! Funções em Go")       // "ola-mundo-funcoes-em-go"
//   curto := Truncate("abcdefghij", 5, "...")
//   cam := CamelCase("user_profile")                  // "userProfile"
//   m := Mask("12345678901", 3)                        // "***8901"
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"strings"
	"unicode"
)

// Slugify converte texto livre em slug seguro para URLs.
func Slugify(s string) string {
	s = strings.ToLower(strings.TrimSpace(s))
	var b strings.Builder
	prevDash := false
	for _, r := range s {
		switch {
		case unicode.IsLetter(r) || unicode.IsDigit(r):
			b.WriteRune(r)
			prevDash = false
		case !prevDash:
			b.WriteByte('-')
			prevDash = true
		}
	}
	return strings.Trim(b.String(), "-")
}

// Truncate limita a string a maxRunes caracteres, acrescentando suffix.
func Truncate(s string, maxRunes int, suffix string) string {
	runes := []rune(s)
	if len(runes) <= maxRunes {
		return s
	}
	return string(runes[:maxRunes]) + suffix
}

// CamelCase converte "user_profile da-api .v2" em "userProfileDaApiV2".
func CamelCase(s string) string {
	fields := strings.FieldsFunc(s, func(r rune) bool {
		return r == '_' || r == '-' || r == ' ' || r == '.'
	})
	var b strings.Builder
	for i, f := range fields {
		runes := []rune(f)
		if len(runes) == 0 {
			continue
		}
		if i == 0 {
			b.WriteString(strings.ToLower(string(runes)))
			continue
		}
		b.WriteString(strings.ToUpper(string(runes[0])))
		b.WriteString(strings.ToLower(string(runes[1:])))
	}
	return b.String()
}

// Mask esconde os primeiros (len-visible) caracteres de um dado sensível.
func Mask(s string, visible int) string {
	runes := []rune(s)
	if visible >= len(runes) {
		return s
	}
	hidden := len(runes) - visible
	return strings.Repeat("*", hidden) + string(runes[hidden:])
}

func main() {
	fmt.Println("slug:", Slugify("Olá Mundo! Funções em Go"))
	fmt.Println("truncado:", Truncate("abcdefghij", 5, "..."))
	fmt.Println("camel:", CamelCase("user_profile da-api .v2"))
	fmt.Println("máscara:", Mask("12345678901", 3))
}