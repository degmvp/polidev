// ==========================================================
// POLYDEV | Go Engineering
// GOENG-09 — Pipeline Genérico (Map / Filter / Reduce)
// ==========================================================
//
// Tema:
// Concorrência, generics, channels e composição funcional.
//
// Descrição:
// Implementa um pipeline genérico com estágios funcionais:
// From, Map, Filter e Reduce.
//
// Cada estágio produtor roda em sua própria goroutine,
// propagando encerramento por close() em cascata e respeitando
// context.Context para cancelamento cooperativo.
//
// Ideal para processamento de streams, transformação de dados,
// filtros encadeados, ETL leve e pipelines concorrentes.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package pipeline

import "context"

func From[T any](ctx context.Context, src []T) <-chan T {
	out := make(chan T)
	go func() {
		defer close(out)
		for _, v := range src {
			select {
			case out <- v:
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}

func Map[T, R any](ctx context.Context, in <-chan T, fn func(T) R) <-chan R {
	out := make(chan R)
	go func() {
		defer close(out)
		for v := range in {
			select {
			case out <- fn(v):
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}

func Filter[T any](ctx context.Context, in <-chan T, pred func(T) bool) <-chan T {
	out := make(chan T)
	go func() {
		defer close(out)
		for v := range in {
			if !pred(v) {
				continue
			}
			select {
			case out <- v:
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}

func Reduce[T, A any](in <-chan T, init A, fn func(A, T) A) A {
	acc := init
	for v := range in {
		acc = fn(acc, v)
	}
	return acc
}