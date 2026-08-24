// wx-go-004-wxgo.go
//
// Título:    Rate limiter (token bucket)
// Descrição: Controla a taxa de operações por segundo com o algoritmo
//            "token bucket", thread-safe. Permite um burst máximo e vai
//            reabastecendo tokens ao longo do tempo. Útil para proteger
//            APIs externas, limitar uso de recursos ou evitar abuso.
//
// Exemplo:
//   rl := NewRateLimiter(2, 2) // 2 ops/s, burst de 2
//   if rl.Allow() { ... }      // true/false
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
	"time"
)

// RateLimiter é um token bucket thread-safe.
type RateLimiter struct {
	mu         sync.Mutex
	capacity   float64 // burst máximo
	tokens     float64
	refillRate float64 // tokens por segundo
	lastRefill time.Time
}

// NewRateLimiter cria um limitador com taxa rate (ops/s) e capacidade burst.
func NewRateLimiter(rate float64, capacity float64) *RateLimiter {
	return &RateLimiter{
		capacity:   capacity,
		tokens:     capacity,
		refillRate: rate,
		lastRefill: time.Now(),
	}
}

// Allow consome um token se disponível e retorna true.
func (r *RateLimiter) Allow() bool {
	r.mu.Lock()
	defer r.mu.Unlock()

	now := time.Now()
	elapsed := now.Sub(r.lastRefill).Seconds()
	r.tokens = min(r.capacity, r.tokens+elapsed*r.refillRate)
	r.lastRefill = now

	if r.tokens >= 1 {
		r.tokens--
		return true
	}
	return false
}

func min(a, b float64) float64 {
	if a < b {
		return a
	}
	return b
}

func main() {
	rl := NewRateLimiter(2, 2) // 2 ops/s com burst de 2
	for i := 1; i <= 6; i++ {
		fmt.Printf("requisição %d permitida? %v\n", i, rl.Allow())
	}
	time.Sleep(1100 * time.Millisecond)
	fmt.Printf("após 1,1s de espera: %v\n", rl.Allow())
}