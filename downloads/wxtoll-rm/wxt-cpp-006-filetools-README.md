# POLYDEV | WX-TOOLS | C++ | 006 — FileTools

## Visão geral

O **FileTools v1.0** é um utilitário de linha de comando em **C++17** para operações com arquivos, desenvolvido para funcionar tanto em **Linux (Ubuntu 24.04)** quanto em **Windows 11**.

A ferramenta reúne quatro comandos principais para busca, limpeza, organização e verificação de integridade de arquivos, com interface simples e saída colorida no terminal.

## Comandos principais

| Comando | Descrição |
|---|---|
| `find` | Procura arquivos por nome, extensão, tamanho ou data de modificação |
| `clean` | Limpa arquivos temporários e diretórios de cache |
| `organize` | Organiza arquivos por categoria com base na extensão |
| `hash` | Calcula hashes SHA-256 e MD5 |

## Principais características

- Multiplataforma: Linux e Windows.
- C++17.
- Uso de guards `#ifdef _WIN32`.
- Cores ANSI no terminal.
- No Windows, ativa `ENABLE_VIRTUAL_TERMINAL_PROCESSING`.
- Barras de progresso para operações demoradas.
- Modo `dry-run` para simular operações sem modificar arquivos.
- Implementação própria de SHA-256 e MD5 em C++17.
- Sem dependências externas.
- Parser de linha de comando com flags, opções com valor e argumentos posicionais.

## Exemplos de uso

### Encontrar arquivos C++

```text
filetools find --dir . --ext=cpp
```

Exemplo de saída:

```text
Buscando arquivos (*.cpp) em ...

./src/main.cpp              12.4 KB
./src/utils.cpp              8.7 KB
./include/filetools.cpp      6.1 KB

Total: 3 arquivo(s) encontrado(s).
```

### Encontrar arquivos grandes

```text
filetools find --dir . --size=100M
```

### Limpar temporários em modo de simulação

```text
filetools clean --tmp --dry-run
```

O `--dry-run` permite verificar antecipadamente o que seria afetado sem realizar alterações.

### Organizar arquivos por categoria

```text
filetools organize --dir "C:\Projetos"
```

### Calcular hashes

```text
filetools hash "arquivo.iso"
```

Exemplo:

```text
Arquivo: arquivo.cpp
SHA-256: 3f2a6e9c4b7d8c1e0f2a8d9c6e7f4b1c8d9e0f2a6e7...
MD5    : 9a3f4d2e1b6c8d7e5f4a3c2b1e0d9f8a
```

## Compilação — Linux

Ubuntu 24.04 / g++:

```bash
g++ -std=c++17 -O2 -o filetools     filetools.cpp -lstdc++fs
```

## Compilação — Windows

Visual Studio 2022:

```text
cl /std:c++17 /O2 ^
   filetools.cpp /Fe:filetools.exe
```

## Benefícios

O FileTools fornece uma interface única para tarefas comuns de administração de arquivos:

- busca avançada;
- limpeza segura;
- organização automática;
- verificação de integridade;
- funcionamento equivalente em Linux e Windows;
- ausência de dependências externas.

## Aplicações

É indicado para:

- desenvolvedores;
- administradores de sistema;
- organização de ambientes de desenvolvimento;
- rotinas de manutenção e limpeza;
- estudos e aprendizado de C++17;
- ambientes mistos Linux/Windows.

## Segurança

Para operações que podem modificar o sistema de arquivos, o modo `--dry-run` permite realizar uma simulação antes da execução efetiva.

Essa abordagem facilita conferir quais arquivos serão afetados antes de qualquer alteração.

## Filosofia

**Arquivos organizados, ideias mais produtivas.**

O WX-TOOLS 006 reúne pequenas operações recorrentes de arquivos em um único utilitário C++ multiplataforma, leve e eficiente.

---

**POLYDEV | WX-TOOLS | C++ | 006 — FileTools v1.0**  
*Ferramentas reais para desenvolvedores reais.*
