// wx-go-015-wxgo.go
//
// Título:    Limitador de concorrência (semáforo com canais)
// Descrição: Semaphore controla quantas goroutines podem executar ao mesmo
//            tempo usando um canal com capacidade fixa (padrão token).
//            Run() executa fn respeitando o limite, bloqueando quem exceder a
//            cota. Útil para limitar conexões, I/O e uso de memória.
//
// Exemplo:
//   sem := NewSemaphore(2) // no máximo 2 execuções simultâneas
//   sem.Run(func() { processar() })
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
	"time"
)

// Semaphore limita execuções concorrentes usando um canal com capacidade n.
type Semaphore struct {
	tokens chan struct{}
}

// NewSemaphore cria um semáforo com limite de n execuções simultâneas.
func NewSemaphore(n int) *Semaphore {
	return &Semaphore{tokens: make(chan struct{}, n)}
}

// Acquire bloqueia até obter um token.
func (s *Semaphore) Acquire() {
	s.tokens <- struct{}{}
}

// Release devolve um token, liberando um slot.
func (s *Semaphore) Release() {
	<-s.tokens
}

// Run executa fn respeitando o limite de concorrência.
func (s *Semaphore) Run(fn func()) {
	s.Acquire()
	defer s.Release()
	fn()
}

func main() {
	sem := NewSemaphore(2) // máximo de 2 concorrentes
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			sem.Run(func() {
				fmt.Printf("task %d iniciou\n", id)
				time.Sleep(100 * time.Millisecond)
				fmt.Printf("task %d terminou\n", id)
			})
		}(i)
	}
	wg.Wait()
	fmt.Println("todas as tasks concluídas")
}