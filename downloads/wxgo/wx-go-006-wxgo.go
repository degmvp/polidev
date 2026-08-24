// wx-go-006-wxgo.go
//
// Título:    Cache em memória com TTL (thread-safe)
// Descrição: Implementa um cache em memória seguro para concorrência, com
//            expiração individual por chave (TTL). Evita bater em banco/API
//            repetidamente para dados que mudam pouco. Inclui Set/Get/Delete
//            e retorno de "miss" quando a chave não existe ou expirou.
//
// Exemplo:
//   c := NewTTLCache()
//   c.Set("chave", "valor", 5*time.Minute)
//   v, ok := c.Get("chave")
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
	"time"
)

type cacheItem struct {
	value     any
	expiresAt time.Time
}

// TTLCache é um cache thread-safe com expiração por item.
type TTLCache struct {
	mu    sync.RWMutex
	items map[string]cacheItem
}

// NewTTLCache cria um cache vazio.
func NewTTLCache() *TTLCache {
	return &TTLCache{items: make(map[string]cacheItem)}
}

// Set armazena value sob key com validade ttl.
func (c *TTLCache) Set(key string, value any, ttl time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.items[key] = cacheItem{value: value, expiresAt: time.Now().Add(ttl)}
}

// Get devolve o valor e true se a chave existir e ainda não expirou.
func (c *TTLCache) Get(key string) (any, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	item, ok := c.items[key]
	if !ok {
		return nil, false
	}
	if time.Now().After(item.expiresAt) {
		return nil, false
	}
	return item.value, true
}

// Delete remove uma chave do cache.
func (c *TTLCache) Delete(key string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.items, key)
}

func main() {
	c := NewTTLCache()
	c.Set("usuarios:42", "Ana Silva", 100*time.Millisecond)

	if v, ok := c.Get("usuarios:42"); ok {
		fmt.Println("cache hit:", v)
	}
	time.Sleep(150 * time.Millisecond)
	if _, ok := c.Get("usuarios:42"); !ok {
		fmt.Println("cache expirado (miss)")
	}
}