// wx-go-016-wxgo.go
//
// Título:    Paginação genérica (offset/limit + metadados)
// Descrição: Paginate divide uma fatia em páginas com offset/limit e devolve
//            metadados úteis para APIs REST: total de registros, total de
//            páginas, flags temPróxima/temAnterior e normalização de valores
//            inválidos (page < 1, pageSize < 1). Funciona com qualquer tipo
//            graças a generics.
//
// Exemplo:
//   p := Paginate(dados, 3, 10)
//   // p.Items, p.Total, p.TotalPages, p.HasNext, p.HasPrevious
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import "fmt"

// Page contém os itens de uma página e seus metadados.
type Page[T any] struct {
	Items       []T  `json:"items"`
	Total       int  `json:"total"`
	Page        int  `json:"page"`
	PageSize    int  `json:"pageSize"`
	TotalPages  int  `json:"totalPages"`
	HasNext     bool `json:"hasNext"`
	HasPrevious bool `json:"hasPrevious"`
}

// Paginate extrai a página (1-based) de uma fatia com os metadados.
func Paginate[T any](items []T, page, pageSize int) Page[T] {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}
	total := len(items)
	totalPages := (total + pageSize - 1) / pageSize
	if totalPages == 0 {
		totalPages = 1
	}

	start := (page - 1) * pageSize
	if start > total {
		start = total
	}
	end := start + pageSize
	if end > total {
		end = total
	}

	return Page[T]{
		Items:       items[start:end],
		Total:       total,
		Page:        page,
		PageSize:    pageSize,
		TotalPages:  totalPages,
		HasNext:     page < totalPages,
		HasPrevious: page > 1,
	}
}

func main() {
	dados := make([]int, 25)
	for i := range dados {
		dados[i] = i + 1
	}

	p := Paginate(dados, 3, 10)
	fmt.Printf("página %d: itens=%v\n", p.Page, p.Items)
	fmt.Printf("total=%d, páginas=%d, temPróxima=%v, temAnterior=%v\n",
		p.Total, p.TotalPages, p.HasNext, p.HasPrevious)
}