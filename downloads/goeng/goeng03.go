// ==========================================================
// POLYDEV | Go Engineering
// GOENG-03 — errgroup com Cancelamento em Cascata
// ==========================================================
//
// Tema:
// Concorrência estruturada com errgroup, context e limite.
//
// Descrição:
// Executa múltiplas operações concorrentes, coleta o primeiro
// erro e cancela automaticamente as demais goroutines por meio
// de um contexto derivado.
//
// Com SetLimit, controla a concorrência sem implementar um
// worker pool manual.
//
// Ideal para chamadas HTTP, consultas externas, leitura paralela
// e processamento distribuído com falha rápida.
//
// Leia • Entenda • Execute seu código.
// ==========================================================

package parallel

import (
	"context"
	"fmt"
	"sync"

	"golang.org/x/sync/errgroup"
)

func FetchAll(
	ctx context.Context,
	urls []string,
	maxConc int,
	fetch func(context.Context, string) ([]byte, error),
) (map[string][]byte, error) {
	g, gctx := errgroup.WithContext(ctx)
	if maxConc > 0 {
		g.SetLimit(maxConc)
	}

	results := make(map[string][]byte, len(urls))
	var mu sync.Mutex

	for _, u := range urls {
		u := u
		g.Go(func() error {
			b, err := fetch(gctx, u)
			if err != nil {
				return fmt.Errorf("fetch %s: %w", u, err)
			}
			mu.Lock()
			results[u] = b
			mu.Unlock()
			return nil
		})
	}

	if err := g.Wait(); err != nil {
		return nil, err
	}
	return results, nil
}