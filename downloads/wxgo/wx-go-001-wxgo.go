// wx-go-001-wxgo.go
//
// Título:    Retry com backoff exponencial + jitter
// Descrição: Executa uma operação que pode falhar de forma transitória (rede,
//            banco de dados, API externa) tentando novamente com intervalos que
//            crescem exponencialmente e com jitter aleatório, evitando o efeito
//            "thundering herd" (muitos clientes tentando no mesmo instante).
//            Respeita o contexto (cancelamento/timeout) e retorna erro se todas
//            as tentativas falharem.
//
// Exemplo:
//   err := Retry(ctx, 5, 100*time.Millisecond, 2.0, func() error {
//       return chamadaExterna()
//   })
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"context"
	"fmt"
	"math/rand"
	"time"
)

// Retry executa fn até obter sucesso ou esgotar maxAttempts tentativas.
// O intervalo entre tentativas cresce como base * multiplier^(n) e recebe
// jitter aleatório para dispersar as tentativas simultâneas.
func Retry(ctx context.Context, maxAttempts int, base time.Duration, multiplier float64, fn func() error) error {
	var lastErr error
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		lastErr = fn()
		if lastErr == nil {
			return nil
		}
		if attempt == maxAttempts {
			break
		}
		delay := time.Duration(float64(base) * pow(multiplier, float64(attempt-1)))
		delay += time.Duration(rand.Int63n(int64(delay/2) + 1)) // jitter de até 50%
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(delay):
		}
	}
	return lastErr
}

// pow calcula base^exp para exp inteiro positivo (sem usar math.Pow).
func pow(base, exp float64) float64 {
	result := 1.0
	for i := 0; i < int(exp); i++ {
		result *= base
	}
	return result
}

func main() {
	attempts := 0
	err := Retry(context.Background(), 4, 50*time.Millisecond, 2.0, func() error {
		attempts++
		fmt.Printf("tentativa %d...\n", attempts)
		if attempts < 3 {
			return fmt.Errorf("falha transitória na rede")
		}
		return nil
	})
	if err != nil {
		fmt.Println("falhou após todas as tentativas:", err)
	} else {
		fmt.Printf("sucesso na tentativa %d\n", attempts)
	}
}