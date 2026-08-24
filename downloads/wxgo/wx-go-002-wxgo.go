// wx-go-002-wxgo.go
//
// Título:    Worker pool concorrente (fan-out / fan-in)
// Descrição: Processa uma lista de tarefas com um número fixo de workers
//            rodando em goroutines. Padrão fan-out: as tarefas são distribuídas
//            por um canal. Padrão fan-in: os resultados são agregados em um
//            canal único. Ideal para processamento em lote (uploads, envio de
//            e-mails, transformação de dados) sem estourar recursos.
//
// Exemplo:
//   resultados := WorkerPool(4, jobs, func(n int) int { return n * n })
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"sync"
)

// WorkerPool consome os valores de jobs com numWorkers goroutines e
// devolve os resultados na mesma ordem em que as tarefas terminam.
func WorkerPool(numWorkers int, jobs <-chan int, process func(int) int) []int {
	resultCh := make(chan int, numWorkers)
	var wg sync.WaitGroup

	// fan-out: lança os workers
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for job := range jobs {
				resultCh <- process(job)
			}
		}()
	}

	// fan-in: fecha o canal de resultados quando todos terminam
	go func() {
		wg.Wait()
		close(resultCh)
	}()

	var results []int
	for r := range resultCh {
		results = append(results, r)
	}
	return results
}

func main() {
	jobs := make(chan int, 10)
	for i := 1; i <= 10; i++ {
		jobs <- i
	}
	close(jobs)

	results := WorkerPool(3, jobs, func(n int) int { return n * n })
	fmt.Println("quadrados processados por 3 workers:", results)
}