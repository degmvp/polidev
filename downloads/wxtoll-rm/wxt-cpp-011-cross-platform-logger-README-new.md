# POLYDEV | WX-TOOLS | C++ | 011 — Cross-Platform Logger

## Visão geral

O **Cross-Platform Logger** é uma biblioteca de logging **C++17 header-only**, leve, portátil e sem dependências externas.

Foi desenvolvida para utilizar o mesmo código em **Windows (MSVC 2022)** e **Linux (GCC/Clang)**, oferecendo saída colorida no console e gravação simultânea em arquivo de log UTF-8.

## Principais recursos

- C++17, implementação header-only.
- Windows com MSVC 2022.
- Linux com GCC ou Clang.
- Sem dependências externas.
- Níveis `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR` e `FATAL`.
- Saída colorida no console.
- Arquivo de log em UTF-8.
- Timestamp com milissegundos.
- Thread ID.
- Nome do arquivo e número da linha.
- Formatação de mensagens com `{}`.
- Suporte a UTF-8 e caracteres acentuados.
- Adequado para aplicações reais.

## Uso rápido

```cpp
#include "CrossPlatformLogger.hpp"

// Exemplo de uso
LOG_INFO("Conectado a {} na porta {}", host, port);
LOG_ERROR("falha ao abrir arquivo: {}", path);
```

Para expressões contendo vírgulas fora de parênteses, como templates com mais de um argumento, utilize parênteses extras:

```cpp
LOG_INFO("{}", (std::make_pair(1, 2)));
```

## Níveis de log

```text
TRACE
DEBUG
INFO
WARN
ERROR
FATAL
```

Cada mensagem pode incluir:

```text
[timestamp] [nível] [thread-id] [arquivo:linha] mensagem
```

## Exemplo de saída

```text
[2026-09-13 14:14:50.746] [TRACE] [33556] [wxt-cpp-011-cross-platform-logger.cpp:583] TRACE - logger iniciado
[2026-09-13 14:14:50.751] [DEBUG] [33556] [wxt-cpp-011-cross-platform-logger.cpp:584] DEBUG - teste de formatacao: 2 + 3 = 5
[2026-09-13 14:14:50.752] [INFO ] [33556] [wxt-cpp-011-cross-platform-logger.cpp:585] INFO - Cross Platform Logger ativo
[2026-09-13 14:14:50.756] [WARN ] [33556] [wxt-cpp-011-cross-platform-logger.cpp:586] WARN - teste de aviso
[2026-09-13 14:14:50.757] [ERROR] [33556] [wxt-cpp-011-cross-platform-logger.cpp:587] ERROR - teste controlado
[2026-09-13 14:14:50.757] [FATAL] [33556] [wxt-cpp-011-cross-platform-logger.cpp:588] FATAL - teste controlado, sem encerrar o processo
[2026-09-13 14:14:50.757] [INFO ] [33556] [wxt-cpp-011-cross-platform-logger.cpp:589] UTF-8 - acentos: informacao, conexao, operacao
```

## Arquivo de log

Durante o teste é criado automaticamente:

```text
wxt-cpp-011-cross-platform-logger.log
```

Formato:

```text
UTF-8
```

O arquivo recebe as mesmas mensagens produzidas no console, permitindo manter um histórico persistente da execução.

## Compilação — Windows

Com Visual Studio 2022 / MSVC:

```text
cl /std:c++17 /EHsc wxt-cpp-011-cross-platform-logger.cpp ^
   /Fe:wxt-cpp-011-cross-platform-logger.exe
```

Também pode ser utilizado diretamente em um projeto do Visual Studio.

## Compilação — Linux

Com GCC:

```bash
g++ -std=c++17 -O2 -pthread     wxt-cpp-011-cross-platform-logger.cpp     -o wxt-cpp-011-cross-platform-logger
```

A implementação também é compatível com Clang.

## Informações do projeto

| Item | Valor |
|---|---|
| Projeto | WX-TOOLS 011 |
| Nome | Cross-Platform Logger |
| Linguagem | C++17 |
| Tipo | Biblioteca header-only |
| Plataformas | Windows / Linux |
| Dependências | Nenhuma |
| Autor | Polydev |
| Licença | Uso livre — projeto Polydev |

## Aplicações

O logger pode ser incorporado a:

- ferramentas CLI;
- utilitários de sistema;
- serviços;
- aplicações de diagnóstico;
- ferramentas de monitoramento;
- projetos multiplataforma;
- aplicações que necessitam de rastreamento persistente em arquivo.

## Filosofia

**Log simples. Portável. Eficiente.**

O objetivo do WX-TOOLS 011 é oferecer o mesmo mecanismo de logging em qualquer plataforma, sem adicionar bibliotecas externas ao projeto.

---

**POLYDEV | WX-TOOLS | C++ | 011 — Cross-Platform Logger**  
*Small tools. Big results.*
