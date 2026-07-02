// ==========================================================
// POLYDEV | Go Engineering
// GOENG-06 — Rate Limiter com Token Bucket
// ==========================================================
//
// Tema:
// Resiliência, HTTP, controle de fluxo e proteção de serviços.
//
// Descrição:
// Implementa rate limiting por chave usando token bucket,
// controlando a taxa de requisições por segundo e o burst
// permitido.
//
// Usa golang.org/x/time/rate.Limiter, padrão robusto do
// ecossistema Go para limitar chamadas, APIs e endpoints.
//
// Ideal para proteger APIs HTTP, reduzir abuso, controlar carga,
// suavizar picos e aumentar a resiliência do sistema.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package ratelimit

import (
	"context"
	"net/http"
	"sync"

	"golang.org/x/time/rate"
)

type PerKeyLimiter struct {
	mu    sync.Mutex
	lim   map[string]*rate.Limiter
	r     rate.Limit
	burst int
}

func New(r rate.Limit, burst int) *PerKeyLimiter {
	return &PerKeyLimiter{
		lim:   make(map[string]*rate.Limiter),
		r:     r,
		burst: burst,
	}
}

func (p *PerKeyLimiter) get(key string) *rate.Limiter {
	p.mu.Lock()
	defer p.mu.Unlock()
	l, ok := p.lim[key]
	if !ok {
		l = rate.NewLimiter(p.r, p.burst)
		p.lim[key] = l
	}
	return l
}

func (p *PerKeyLimiter) Allow(key string) bool {
	return p.get(key).Allow()
}

func (p *PerKeyLimiter) Wait(ctx context.Context, key string) error {
	return p.get(key).Wait(ctx)
}

func (p *PerKeyLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !p.Allow(r.RemoteAddr) {
			w.Header().Set("Retry-After", "1")
			http.Error(w, "rate limited", http.StatusTooManyRequests)
			return
		}
		next.ServeHTTP(w, r)
	})
}