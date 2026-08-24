// wx-go-008-wxgo.go
//
// Título:    Utilitários de tempo: dias úteis, intervalos e formatação
// Descrição: Conjunto de helpers para trabalho com datas em contexto de negócio:
//            contar dias úteis entre datas (ignorando fins de semana e feriados
//            informados), verificar se uma data é dia útil e gerar todos os dias
//            de um intervalo. Útil para relatórios, férias, prazos e agendas.
//
// Exemplo:
//   n := BusinessDaysBetween(inicio, fim, feriados)
//   dias := DateRange(inicio, fim)
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"time"
)

// truncateDay zera hora/min/seg para comparar apenas a data.
func truncateDay(d time.Time) time.Time {
	y, m, day := d.Date()
	return time.Date(y, m, day, 0, 0, 0, 0, d.Location())
}

// IsBusinessDay indica se d é dia útil (seg-sex e não feriado).
func IsBusinessDay(d time.Time, holidays map[time.Time]bool) bool {
	wd := d.Weekday()
	if wd == time.Saturday || wd == time.Sunday {
		return false
	}
	if holidays != nil && holidays[truncateDay(d)] {
		return false
	}
	return true
}

// BusinessDaysBetween conta os dias úteis no intervalo [start, end] (inclusivo).
func BusinessDaysBetween(start, end time.Time, holidays map[time.Time]bool) int {
	count := 0
	for d := truncateDay(start); !d.After(truncateDay(end)); d = d.AddDate(0, 0, 1) {
		if IsBusinessDay(d, holidays) {
			count++
		}
	}
	return count
}

// DateRange devolve todas as datas (inclusive) do intervalo.
func DateRange(start, end time.Time) []time.Time {
	var out []time.Time
	for d := truncateDay(start); !d.After(truncateDay(end)); d = d.AddDate(0, 0, 1) {
		out = append(out, d)
	}
	return out
}

func main() {
	start := time.Date(2026, 8, 24, 0, 0, 0, 0, time.UTC) // segunda-feira
	end := time.Date(2026, 8, 30, 0, 0, 0, 0, time.UTC)   // domingo

	fmt.Println("dias úteis na semana:", BusinessDaysBetween(start, end, nil))
	fmt.Println("dias no intervalo:", len(DateRange(start, end)))
	fmt.Println("24/08 é dia útil?", IsBusinessDay(start, nil))
}