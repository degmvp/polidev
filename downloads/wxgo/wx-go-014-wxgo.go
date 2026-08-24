// wx-go-014-wxgo.go
//
// Título:    Cliente HTTP com timeout, contexto e retry
// Descrição: HTTPGetWithRetry faz uma requisição GET com timeout por tentativa,
//            respeita o contexto do chamador e repete automaticamente em erros
//            de rede e respostas 5xx (com pequena pausa crescente entre as
//            tentativas). Padrão essencial para integrações robustas.
//
// Exemplo:
//   body, status, err := HTTPGetWithRetry(ctx, client, "https://api.exemplo.com", 3, 3*time.Second)
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"time"
)

// HTTPGetWithRetry faz GET com timeout por tentativa e retry em falhas
// transitórias (rede ou status 5xx), retornando corpo e código de status.
func HTTPGetWithRetry(ctx context.Context, client *http.Client, url string, maxAttempts int, timeout time.Duration) ([]byte, int, error) {
	var lastErr error
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		reqCtx, cancel := context.WithTimeout(ctx, timeout)
		req, err := http.NewRequestWithContext(reqCtx, http.MethodGet, url, nil)
		if err != nil {
			cancel()
			return nil, 0, err
		}

		resp, err := client.Do(req)
		if err != nil {
			cancel()
			lastErr = err
			time.Sleep(time.Duration(attempt) * 200 * time.Millisecond)
			continue
		}

		body, readErr := io.ReadAll(resp.Body)
		resp.Body.Close()
		cancel()
		if readErr != nil {
			lastErr = readErr
			time.Sleep(time.Duration(attempt) * 200 * time.Millisecond)
			continue
		}
		if resp.StatusCode >= 500 && attempt < maxAttempts {
			lastErr = fmt.Errorf("status %d", resp.StatusCode)
			time.Sleep(time.Duration(attempt) * 200 * time.Millisecond)
			continue
		}
		return body, resp.StatusCode, nil
	}
	return nil, 0, fmt.Errorf("todas as tentativas falharam: %w", lastErr)
}

func main() {
	client := &http.Client{}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	body, status, err := HTTPGetWithRetry(ctx, client, "https://httpbin.org/get", 3, 3*time.Second)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	fmt.Printf("status: %d, bytes recebidos: %d\n", status, len(body))
}