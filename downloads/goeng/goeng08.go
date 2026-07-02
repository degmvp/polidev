// ==========================================================
// POLYDEV | Go Engineering
// GOENG-08 — Retry com Exponential Backoff + Jitter
// ==========================================================
//
// Tema:
// Resiliência, retry, backoff exponencial e jitter.
//
// Descrição:
// Executa operações idempotentes com tentativas controladas,
// aplicando backoff exponencial e jitter para evitar sincronização
// de retries entre múltiplos clientes.
//
// O uso de context.Context permite cancelar a operação de forma
// cooperativa, respeitando timeout, deadline ou cancelamento externo.
//
// Ideal para HTTP, APIs externas, filas, bancos de dados,
// microsserviços e integrações sujeitas a falhas transitórias.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package retry

import (
	"context"
	"errors"
	"math/rand"
	"time"
)

type Policy struct {
	Max       int
	Base      time.Duration
	Cap       time.Duration
	Retryable func(error) bool
}

func Do[T any](ctx context.Context, p Policy, fn func(context.Context) (T, error)) (T, error) {
	var zero T
	var lastErr error
	for attempt := 0; attempt <= p.Max; attempt++ {
		v, err := fn(ctx)
		if err == nil {
			return v, nil
		}
		lastErr = err
		if p.Retryable != nil && !p.Retryable(err) {
			return zero, err
		}
		if attempt == p.Max {
			break
		}
		back := p.Base << attempt
		if back <= 0 || back > p.Cap {
			back = p.Cap
		}
		var sleep time.Duration
		if back > 0 {
			sleep = time.Duration(rand.Int63n(int64(back)))
		}
		select {
		case <-time.After(sleep):
		case <-ctx.Done():
			return zero, errors.Join(lastErr, ctx.Err())
		}
	}
	return zero, lastErr
}