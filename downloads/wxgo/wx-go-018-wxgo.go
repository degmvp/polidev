// wx-go-018-wxgo.go
//
// Título:    Carregador de configuração por variáveis de ambiente
// Descrição: Carrega configurações de variáveis de ambiente com valores padrão
//            e conversão segura (int, bool, duration, string). Se a variável
//            não existir ou tiver valor inválido, usa o default — evitando
//            panics e crashs em produção. Padrão 12-factor para configuração.
//
// Exemplo:
//   cfg := LoadConfig()
//   fmt.Println(cfg.Port, cfg.Debug)
//
// Dependências: apenas a biblioteca padrão (stdlib) — sem dependências externas.
package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config reúne as configurações da aplicação.
type Config struct {
	Port     int
	Host     string
	Debug    bool
	Timeout  time.Duration
	Database string
}

// LoadConfig lê variáveis de ambiente com defaults e conversão segura.
func LoadConfig() Config {
	return Config{
		Port:     envInt("APP_PORT", 8080),
		Host:     envStr("APP_HOST", "0.0.0.0"),
		Debug:    envBool("APP_DEBUG", false),
		Timeout:  envDuration("APP_TIMEOUT", 30*time.Second),
		Database: envStr("DATABASE_URL", "postgres://localhost:5432/app"),
	}
}

func envStr(key, def string) string {
	if v, ok := os.LookupEnv(key); ok {
		return v
	}
	return def
}

func envInt(key string, def int) int {
	if v, ok := os.LookupEnv(key); ok {
		if n, err := strconv.Atoi(v); err == nil {
			return n
		}
	}
	return def
}

func envBool(key string, def bool) bool {
	if v, ok := os.LookupEnv(key); ok {
		if b, err := strconv.ParseBool(v); err == nil {
			return b
		}
	}
	return def
}

func envDuration(key string, def time.Duration) time.Duration {
	if v, ok := os.LookupEnv(key); ok {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
	}
	return def
}

func main() {
	// simula variáveis definidas em produção
	os.Setenv("APP_PORT", "9090")

	cfg := LoadConfig()
	fmt.Printf("porta=%d host=%s debug=%v timeout=%s\n",
		cfg.Port, cfg.Host, cfg.Debug, cfg.Timeout)
	fmt.Println("database:", cfg.Database)
}