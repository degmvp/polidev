// wx-go-005-wxgo.go
//
// Título:    Circuit breaker
// Descrição: Protege chamadas a um serviço instável (banco, API externa)
//            evitando sobrecarga quando ele está falhando. Estados:
//            FECHADO (deixa passar; conta falhas), ABERTO (rejeita rápido por
//            um cooldown) e SEMIABERTO (permite uma sonda para testar a
//            recuperação). Padrão clássico de resiliência em sistemas
//            distribuídos.
//
// Exemplo:
//   cb := NewCircuitBreaker(3, 500*time.Millisecond)
//   err := cb.Call(func() error { return chamarServico() })
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
	"time"
)

// State representa o estado do circuit breaker.
type State int

const (
	StateClosed   State = iota // permitindo chamadas
	StateOpen                  // rejeitando chamadas (fast fail)
	StateHalfOpen              // sonda de recuperação
)

// CircuitBreaker controla o acesso a um serviço com falhas.
type CircuitBreaker struct {
	mu               sync.Mutex
	state            State
	failures         int
	failureThreshold int
	cooldown         time.Duration
	openedAt         time.Time
}

// NewCircuitBreaker cria um breaker que abre após threshold falhas e
// permanece aberto por cooldown.
func NewCircuitBreaker(threshold int, cooldown time.Duration) *CircuitBreaker {
	return &CircuitBreaker{
		failureThreshold: threshold,
		cooldown:         cooldown,
		state:            StateClosed,
	}
}

// Call executa fn respeitando o estado do breaker.
func (c *CircuitBreaker) Call(fn func() error) error {
	c.mu.Lock()
	switch c.state {
	case StateOpen:
		if time.Since(c.openedAt) > c.cooldown {
			c.state = StateHalfOpen
		} else {
			c.mu.Unlock()
			return fmt.Errorf("circuito aberto (fast fail)")
		}
	}
	c.mu.Unlock()

	err := fn()

	c.mu.Lock()
	defer c.mu.Unlock()
	if err != nil {
		c.failures++
		if c.failures >= c.failureThreshold && c.state != StateOpen {
			c.state = StateOpen
			c.openedAt = time.Now()
			c.failures = 0
		}
	} else {
		c.failures = 0
		if c.state == StateHalfOpen {
			c.state = StateClosed
		}
	}
	return err
}

func main() {
	cb := NewCircuitBreaker(3, 300*time.Millisecond)
	for i := 1; i <= 6; i++ {
		err := cb.Call(func() error { return fmt.Errorf("serviço indisponível") })
		fmt.Printf("chamada %d -> erro: %v\n", i, err)
	}
	// após o cooldown, a sonda tenta de novo e falha, mantendo o circuito aberto
	time.Sleep(350 * time.Millisecond)
	err := cb.Call(func() error { return fmt.Errorf("serviço ainda indisponível") })
	fmt.Println("sonda pós-cooldown ->", err)
}