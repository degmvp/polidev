// wx-go-019-wxgo.go
//
// Título:    Logger estruturado em JSON
// Descrição: Logger simples e thread-safe que emite linhas em JSON com nível
//            (debug/info/warn/error), timestamp e campos extras por evento.
//            Saída estruturada facilita ingestão por ferramentas de observação
//            (ELK, Grafana, CloudWatch) e filtragem automatizada de logs.
//
// Exemplo:
//   log := NewLogger(os.Stdout, LevelInfo)
//   log.Info("servidor iniciado", map[string]any{"port": 8080})
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"sync"
	"time"
)

// Level representa a severidade do log.
type Level int

const (
	LevelDebug Level = iota
	LevelInfo
	LevelWarn
	LevelError
)

func (l Level) String() string {
	return [...]string{"debug", "info", "warn", "error"}[l]
}

// Logger escreve logs JSON estruturados de forma thread-safe.
type Logger struct {
	mu    sync.Mutex
	out   *os.File
	level Level
}

// NewLogger cria um logger que grava em out a partir do nível level.
func NewLogger(out *os.File, level Level) *Logger {
	return &Logger{out: out, level: level}
}

func (l *Logger) log(lv Level, msg string, fields map[string]any) {
	if lv < l.level {
		return
	}
	l.mu.Lock()
	defer l.mu.Unlock()

	entry := map[string]any{
		"level":     lv.String(),
		"message":   msg,
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	}
	for k, v := range fields {
		entry[k] = v
	}
	data, _ := json.Marshal(entry)
	fmt.Fprintln(l.out, string(data))
}

// Debug registra um evento de depuração.
func (l *Logger) Debug(msg string, fields map[string]any) { l.log(LevelDebug, msg, fields) }

// Info registra um evento informativo.
func (l *Logger) Info(msg string, fields map[string]any) { l.log(LevelInfo, msg, fields) }

// Error registra um evento de erro.
func (l *Logger) Error(msg string, fields map[string]any) { l.log(LevelError, msg, fields) }

func main() {
	logger := NewLogger(os.Stdout, LevelDebug)

	logger.Info("servidor iniciado", map[string]any{"port": 8080})
	logger.Debug("cache miss", map[string]any{"key": "usuarios"})
	logger.Error("falha ao conectar", map[string]any{"db": "principal", "erro": "timeout"})
}