# POLYDEV | WX-TOOLS | C++ | 012 — FileWatcher

## Visão geral

O **FileWatcher** é uma biblioteca **C++17 multiplataforma** da coleção WX-TOOLS para monitoramento, em tempo real, de alterações em arquivos e diretórios.

A ferramenta detecta eventos de criação, modificação, renomeação e exclusão, oferecendo uma API simples, leve e sem dependências externas.

## Eventos monitorados

O FileWatcher identifica os principais eventos do sistema de arquivos:

- **CREATED** — criação de arquivos e diretórios.
- **MODIFIED** — alteração de conteúdo.
- **RENAMED** — renomeação.
- **DELETED** — exclusão de arquivos e diretórios.

## Plataformas suportadas

### Windows 11

Utiliza o mecanismo nativo:

```text
ReadDirectoryChangesW
```

### Linux / Ubuntu 24.04

Utiliza:

```text
inotify
```

Isso permite manter uma interface comum em C++ enquanto cada plataforma utiliza seu mecanismo nativo de monitoramento.

## Principais características

- API simples e objetiva.
- Suporte a arquivos e diretórios.
- Eventos em tempo real.
- Multiplataforma: Windows e Linux.
- C++17 com `std::filesystem`.
- Leve e sem dependências externas.
- Tratamento de encerramento com `Ctrl+C`.

## Arquivos do módulo

```text
wxt-cpp-012-filewatcher.hpp
wxt-cpp-012-filewatcher.cpp
README.md
```

### `wxt-cpp-012-filewatcher.hpp`

Implementação principal do módulo em formato header-only.

### `wxt-cpp-012-filewatcher.cpp`

Programa de exemplo para demonstração e teste da biblioteca.

## Testes e homologação

### Windows 11 / Visual Studio 2022

```text
Compilação : 0 warnings / 0 errors
Eventos    : CREATED, RENAMED, DELETED
Encerramento: OK
```

### Ubuntu 24.04 / g++

```text
Compilação : sem warnings / 0 errors
Eventos    : CREATED, RENAMED, DELETED
Encerramento: OK
```

O módulo foi homologado nas duas plataformas.

## Exemplo de execução

Uma aplicação típica pode monitorar um diretório e apresentar os eventos conforme ocorrem:

```text
fwdemo — monitorando: E:\FWTEST
modo: recursivo | debounce: 250 ms | Ctrl+C para sair

16:47:51  CREATED   arquivo.txt
16:48:03  MODIFIED  arquivo.txt
16:48:20  RENAMED   arquivo.txt -> arquivo2.txt
16:48:35  DELETED   arquivo2.txt
```

## Aplicações

O FileWatcher pode ser utilizado em:

- sincronização de arquivos;
- monitoramento de diretórios;
- sistemas de build automático;
- processamento de arquivos recém-criados;
- auditoria de alterações;
- atualização automática de caches;
- ferramentas de desenvolvimento;
- automações locais;
- serviços que precisam reagir a mudanças no filesystem.

## Requisitos

- Compilador compatível com **C++17**.
- Windows ou Linux.
- `std::filesystem`.
- Nenhuma biblioteca externa.

## Status

```text
WX-TOOLS 012
FileWatcher

HOMOLOGADO
FONTE CONGELADO
```

Após os testes em Windows 11 e Ubuntu 24.04, o código foi considerado homologado e congelado.

---

**WX-TOOLS | C++ | 012 — FileWatcher**  
*Small Tools. Big Results.*  
*Observe o que importa. Em tempo real.*
