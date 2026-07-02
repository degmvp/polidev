// ==========================================================
// POLYDEV | Go Engineering
// GOENG-05 — sync.Pool para Redução de Alocações
// ==========================================================
//
// Tema:
// Performance, gerenciamento de memória e Garbage Collector.
//
// Descrição:
// Utiliza sync.Pool para reutilizar objetos temporários,
// reduzindo alocações, pressão sobre o Garbage Collector
// e custos de processamento em caminhos críticos.
//
// Objetos grandes podem ser descartados para evitar retenção
// excessiva de memória.
//
// Ideal para buffers HTTP, serializadores, parsers,
// compressão, geração de JSON/XML e processamento intensivo.
//
// Leia • Entenda • Execute seu código.
// ==========================================================
package bufpool

import (
	"bytes"
	"io"
	"sync"
)

const maxKeep = 1 << 20 // 1 MiB

var pool = sync.Pool{
	New: func() any { return new(bytes.Buffer) },
}

func Get() *bytes.Buffer {
	return pool.Get().(*bytes.Buffer)
}

func Put(b *bytes.Buffer) {
	if b == nil {
		return
	}
	if b.Cap() > maxKeep {
		return
	}
	b.Reset()
	pool.Put(b)
}

func Encode(w io.Writer, fn func(*bytes.Buffer) error) error {
	buf := Get()
	defer Put(buf)
	if err := fn(buf); err != nil {
		return err
	}
	_, err := buf.WriteTo(w)
	return err
}