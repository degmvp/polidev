// ==========================================================
// POLYDEV | Go Engineering
// GOENG-04 — Singleflight para Deduplicação de Chamadas
// ==========================================================
//
// Tema:
// Concorrência, cache, generics e controle de thundering herd.
//
// Descrição:
// Usa singleflight.Group para garantir que chamadas concorrentes
// com a mesma chave compartilhem uma única execução.
//
// Combina cache com TTL e deduplicação de chamadas para evitar
// sobrecarga em banco, HTTP, APIs externas ou serviços lentos.
//
// Ideal para caches sob alta concorrência, loaders, gateways,
// catálogos remotos e sistemas com risco de thundering herd.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package cache

import (
	"context"
	"sync"
	"time"

	"golang.org/x/sync/singleflight"
)

type entry[V any] struct {
	v   V
	exp time.Time
}

type Loader[V any] struct {
	sf    singleflight.Group
	cache sync.Map
	TTL   time.Duration
}

func (l *Loader[V]) Get(
	ctx context.Context,
	key string,
	load func(context.Context) (V, error),
) (V, error) {
	if e, ok := l.cache.Load(key); ok {
		en := e.(entry[V])
		if time.Now().Before(en.exp) {
			return en.v, nil
		}
	}

	v, err, _ := l.sf.Do(key, func() (any, error) {
		val, err := load(ctx)
		if err != nil {
			return nil, err
		}
		l.cache.Store(key, entry[V]{v: val, exp: time.Now().Add(l.TTL)})
		return val, nil
	})
	if err != nil {
		var zero V
		return zero, err
	}
	return v.(V), nil
}