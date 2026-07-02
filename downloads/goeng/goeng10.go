// ==========================================================
// POLYDEV | Go Engineering
// GOENG-10 — Graceful Shutdown de Servidor HTTP
// ==========================================================
//
// Tema:
// Produção, HTTP, Kubernetes e encerramento controlado.
//
// Descrição:
// Implementa encerramento suave de servidor HTTP,
// parando de aceitar novas conexões, drenando requisições
// em andamento com deadline e executando hooks de limpeza.
//
// Fundamental em ambientes de produção, containers e Kubernetes,
// onde SIGTERM antecede o encerramento forçado do processo.
//
// Ideal para APIs, microsserviços, gateways, serviços internos,
// workers HTTP e aplicações cloud-native.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package httpserver

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os/signal"
	"syscall"
	"time"
)

type Cleanup func(context.Context) error

func Run(addr string, handler http.Handler, drainTimeout time.Duration, cleanups ...Cleanup) error {
	srv := &http.Server{
		Addr:              addr,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	errCh := make(chan error, 1)
	go func() {
		slog.Info("http listening", "addr", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
		close(errCh)
	}()

	select {
	case <-ctx.Done():
		slog.Info("shutdown signal received")
	case err := <-errCh:
		return err
	}

	shutCtx, cancel := context.WithTimeout(context.Background(), drainTimeout)
	defer cancel()

	if err := srv.Shutdown(shutCtx); err != nil {
		slog.Error("forced shutdown", "err", err)
		_ = srv.Close()
	}

	for _, c := range cleanups {
		if err := c(shutCtx); err != nil {
			slog.Error("cleanup failed", "err", err)
		}
	}
	return nil
}