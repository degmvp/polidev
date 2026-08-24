// wx-go-020-wxgo.go
//
// Título:    Barramento pub/sub em memória
// Descrição: PubSub é um barramento de eventos em memória, thread-safe, com
//            tópicos e múltiplos assinantes por tópico. Publish entrega a
//            mensagem a todos os assinantes do tópico sem bloquear o produtor
//            (buffers com descarte em caso de cheio). Útil para eventos de
//            domínio, notificações e desacoplamento entre módulos.
//
// Exemplo:
//   ps := NewPubSub()
//   ch := ps.Subscribe("pedidos", 4)
//   ps.Publish("pedidos", "pedido criado")
//   msg := <-ch
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
)

// PubSub é um barramento pub/sub em memória.
type PubSub struct {
	mu     sync.RWMutex
	topics map[string][]chan any
}

// NewPubSub cria um barramento vazio.
func NewPubSub() *PubSub {
	return &PubSub{topics: make(map[string][]chan any)}
}

// Subscribe cria um canal para receber mensagens do tópico (buffer opcional).
func (p *PubSub) Subscribe(topic string, buffer int) chan any {
	ch := make(chan any, buffer)
	p.mu.Lock()
	defer p.mu.Unlock()
	p.topics[topic] = append(p.topics[topic], ch)
	return ch
}

// Unsubscribe remove o assinante e fecha o seu canal.
func (p *PubSub) Unsubscribe(topic string, ch chan any) {
	p.mu.Lock()
	defer p.mu.Unlock()
	subs := p.topics[topic]
	for i, c := range subs {
		if c == ch {
			p.topics[topic] = append(subs[:i], subs[i+1:]...)
			close(ch)
			return
		}
	}
}

// Publish envia msg a todos os assinantes do tópico sem bloquear o produtor.
func (p *PubSub) Publish(topic string, msg any) {
	p.mu.RLock()
	subs := append([]chan any(nil), p.topics[topic]...)
	p.mu.RUnlock()
	for _, ch := range subs {
		select {
		case ch <- msg:
		default: // buffer cheio: descarta para não bloquear
		}
	}
}

func main() {
	ps := NewPubSub()
	ch1 := ps.Subscribe("pedidos", 4)
	ch2 := ps.Subscribe("pedidos", 4)

	ps.Publish("pedidos", "pedido #1001 criado")
	ps.Publish("pedidos", "pedido #1002 criado")

	fmt.Println("assinante 1:", <-ch1, "|", <-ch1)
	fmt.Println("assinante 2:", <-ch2, "|", <-ch2)

	ps.Unsubscribe("pedidos", ch1)
	ps.Publish("pedidos", "pedido #1003 criado")
	fmt.Println("assinante 2 após saída do assinante 1:", <-ch2)
}