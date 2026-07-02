// ==========================================================
// POLYDEV | Go Engineering
// GOENG-02 — Fan-Out / Fan-In Genérico
// ==========================================================
//
// Tema:
// Concorrência com channels e generics.
//
// Descrição:
// Fan-Out distribui um stream de entrada em N consumidores.
// Fan-In reagrega múltiplos channels em um único channel.
//
// Diferente de um worker pool tradicional, cada consumidor pode
// aplicar lógica diferente, ou o mesmo processamento sobre
// partições distintas do fluxo.
//
// Ideal para pipelines concorrentes, processamento paralelo,
// divisão de carga e recomposição de resultados.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package fanio

import "sync"

func FanIn[T any](chs ...<-chan T) <-chan T {
	out := make(chan T)
	var wg sync.WaitGroup
	wg.Add(len(chs))
	for _, c := range chs {
		go func(c <-chan T) {
			defer wg.Done()
			for v := range c {
				out <- v
			}
		}(c)
	}
	go func() { wg.Wait(); close(out) }()
	return out
}

func FanOut[T any](in <-chan T, n int) []<-chan T {
	if n <= 0 {
		n = 1
	}
	outs := make([]chan T, n)
	for i := range outs {
		outs[i] = make(chan T)
	}
	go func() {
		defer func() {
			for _, c := range outs {
				close(c)
			}
		}()
		i := 0
		for v := range in {
			outs[i] <- v
			i = (i + 1) % n
		}
	}()
	res := make([]<-chan T, n)
	for i, c := range outs {
		res[i] = c
	}
	return res
}