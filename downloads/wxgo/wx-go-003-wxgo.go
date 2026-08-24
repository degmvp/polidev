// wx-go-003-wxgo.go
//
// Título:    Funções genéricas Map / Filter / Reduce
// Descrição: Utilitários de coleções com generics do Go, permitindo transformar,
//            filtrar e reduzir fatias de qualquer tipo sem duplicar código.
//            Map aplica uma função a cada item; Filter mantém os itens que
//            satisfazem um predicado; Reduce acumula valores em um resultado.
//
// Exemplo:
//   dobrados := Map(nums, func(n int) int { return n * 2 })
//   pares    := Filter(nums, func(n int) bool { return n%2 == 0 })
//   soma     := Reduce(nums, 0, func(acc, n int) int { return acc + n })
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import "fmt"

// Map transforma cada item de uma fatia aplicando fn (T -> U).
func Map[T, U any](items []T, fn func(T) U) []U {
	out := make([]U, len(items))
	for i, it := range items {
		out[i] = fn(it)
	}
	return out
}

// Filter mantém apenas os itens para os quais fn retorna true.
func Filter[T any](items []T, fn func(T) bool) []T {
	out := make([]T, 0, len(items))
	for _, it := range items {
		if fn(it) {
			out = append(out, it)
		}
	}
	return out
}

// Reduce combina todos os itens em um único valor acumulado.
func Reduce[T, U any](items []T, initial U, fn func(U, T) U) U {
	acc := initial
	for _, it := range items {
		acc = fn(acc, it)
	}
	return acc
}

func main() {
	nums := []int{1, 2, 3, 4, 5, 6}

	doubled := Map(nums, func(n int) int { return n * 2 })
	evens := Filter(nums, func(n int) bool { return n%2 == 0 })
	sum := Reduce(nums, 0, func(acc, n int) int { return acc + n })

	fmt.Println("dobro:", doubled)
	fmt.Println("pares:", evens)
	fmt.Println("soma:", sum)
}