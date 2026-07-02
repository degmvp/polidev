// ==========================================================
// POLYDEV | Go Engineering
// GOENG-01 — Worker Pool com Context e Backpressure
// ==========================================================
//
// Tema:
// Concorrência com context.Context, channels e generics.
//
// Descrição:
// Pool de workers que consome tarefas de um channel limitado,
// aproveitando backpressure natural, respeitando context.Context
// para cancelamento cooperativo e retornando erros individualmente
// em cada resultado.
//
// Ideal para processamento em lote de I/O como HTTP, banco de dados
// e arquivos, quando é necessário limitar concorrência sem estourar
// recursos.
//
// Leia • Entenda • Execute seu código.
// ==========================================================

package workerpool

import (
	"context"
	"sync"
)

type Task[T any, R any] struct {
	In  T
	Out R
	Err error
}

// Run executa fn em até `workers` goroutines. Fecha out quando termina.
func Run[T any, R any](
	ctx context.Context,
	workers int,
	in <-chan T,
	fn func(context.Context, T) (R, error),
) <-chan Task[T, R] {
	out := make(chan Task[T, R], workers)
	var wg sync.WaitGroup
	wg.Add(workers)

	for i := 0; i < workers; i++ {
		go func() {
			defer wg.Done()
			for {
				select {
				case <-ctx.Done():
					return
				case v, ok := <-in:
					if !ok {
						return
					}
					r, err := fn(ctx, v)
					select {
					case out <- Task[T, R]{In: v, Out: r, Err: err}:
					case <-ctx.Done():
						return
					}
				}
			}
		}()
	}

	go func() {
		wg.Wait()
		close(out)
	}()
	return out
}

// ==========================================================
// Casos de Uso
// ==========================================================
//
// 1. Enriquecer milhares de registros chamando APIs externas.
// 2. Processar arquivos em lote com paralelismo controlado.
// 3. Executar consultas em banco sem sobrecarregar o servidor.
// 4. Consumir tarefas de filas internas.
// 5. Construir etapas paralelas em pipelines ETL.
//
// ==========================================================
// Pontos de Atenção
// ==========================================================
//
// 1. O código retorna o erro em Task.Err.
// 2. Ele não cancela automaticamente no primeiro erro.
// 3. Para cancelar no primeiro erro, use context.WithCancel no chamador.
// 4. O backpressure depende do uso de channels limitados.
// 5. A função fn precisa respeitar context.Context.
// 6. workers deve ser maior que zero.
//
// ==========================================================
// Benefícios
// ==========================================================
//
// - Limita concorrência.
// - Evita explosão de goroutines.
// - Facilita cancelamento cooperativo.
// - Funciona com qualquer tipo de entrada e saída.
// - É reutilizável em sistemas de I/O intensivo.
//
// ==========================================================
// POLYDEV | GOENG-01 finalizado
// Leia • Entenda • Execute seu código.
// ==========================================================