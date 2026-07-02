// ==========================================================
// POLYDEV | Go Engineering
// GOENG-07 — Circuit Breaker (Closed / Open / Half-Open)
// ==========================================================
//
// Tema:
// Resiliência, tolerância a falhas e sistemas distribuídos.
//
// Descrição:
// Implementa o padrão Circuit Breaker para interromper chamadas
// a serviços degradados, evitando efeito cascata e reduzindo
// tempo de recuperação.
//
// O circuito opera em três estados:
//
// • Closed    → chamadas executadas normalmente.
// • Open      → chamadas bloqueadas imediatamente.
// • Half-Open → permite chamadas de teste para verificar
//               se o serviço voltou ao normal.
//
// Ideal para APIs, microsserviços, bancos de dados,
// filas, serviços externos e integrações críticas.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package breaker

import (
	"errors"
	"sync"
	"time"
)

type State int

const (
	Closed State = iota
	Open
	HalfOpen
)

var ErrOpen = errors.New("circuit breaker: open")

type Breaker struct {
	mu           sync.Mutex
	state        State
	failures     int
	threshold    int
	cooldown     time.Duration
	openedAt     time.Time
	halfOpenProb int
	now          func() time.Time
}

func New(threshold int, cooldown time.Duration) *Breaker {
	return &Breaker{
		threshold:    threshold,
		cooldown:     cooldown,
		halfOpenProb: 1,
		now:          time.Now,
	}
}

func (b *Breaker) Do(fn func() error) error {
	b.mu.Lock()
	switch b.state {
	case Open:
		if b.now().Sub(b.openedAt) < b.cooldown {
			b.mu.Unlock()
			return ErrOpen
		}
		b.state = HalfOpen
		b.halfOpenProb = 1
	case HalfOpen:
		if b.halfOpenProb <= 0 {
			b.mu.Unlock()
			return ErrOpen
		}
		b.halfOpenProb--
	}
	b.mu.Unlock()

	err := fn()

	b.mu.Lock()
	defer b.mu.Unlock()
	if err != nil {
		b.failures++
		if b.state == HalfOpen || b.failures >= b.threshold {
			b.state = Open
			b.openedAt = b.now()
			b.halfOpenProb = 1
		}
		return err
	}
	b.failures = 0
	b.state = Closed
	return nil
}