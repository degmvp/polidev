// wx-go-013-wxgo.go
//
// Título:    Desligamento gracioso de servidor HTTP
// Descrição: Sobe um servidor HTTP e aguarda um sinal de encerramento
//            (Ctrl+C ou SIGTERM). Ao recebê-lo, faz shutdown com timeout para
//            concluir requisições em andamento antes de sair — evitando
//            requisições cortadas no meio em deploys e reinicializações.
//
// Exemplo:
//   rode o programa e pressione Ctrl+C: ele encerra com segurança.
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "olá, servidor!")
}

func main() {
	srv := &http.Server{
		Addr:    ":8080",
		Handler: http.HandlerFunc(helloHandler),
	}

	// sobe o servidor em goroutine para não bloquear a espera do sinal
	go func() {
		fmt.Println("servidor ouvindo em :8080")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("erro no servidor: %v", err)
		}
	}()

	// aguarda Ctrl+C (SIGINT) ou SIGTERM
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop
	fmt.Println("sinal recebido, encerrando graciosamente...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("falha no shutdown: %v", err)
	}
	fmt.Println("servidor encerrado com segurança")
}