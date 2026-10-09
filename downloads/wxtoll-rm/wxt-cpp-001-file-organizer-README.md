# POLYDEV | WX-TOOLS | C++ | 001 — File Organizer

## Visão geral

O **File Organizer** é um utilitário de linha de comando em **C++17** para organizar automaticamente arquivos de um diretório por categoria, utilizando a extensão de cada arquivo.

Foi projetado para funcionar em **Linux (Ubuntu 24.04)** e **Windows 11**, oferecendo modo de simulação (`dry-run`) para conferir as operações antes de mover qualquer arquivo.

## Principais recursos

- Organização automática por extensão.
- Separação dos arquivos em categorias.
- Suporte a modo `dry-run`.
- Criação automática dos diretórios de destino.
- Logs detalhados com `--verbose`.
- Interface simples via linha de comando.
- Multiplataforma: Linux e Windows.
- C++17.
- Sem dependências externas.

## Comandos principais

| Comando | Descrição |
|---|---|
| `organize` | Organiza arquivos por categoria com base na extensão |
| `--dir <pasta>` | Define o diretório alvo |
| `--dry-run` | Simula as operações sem mover arquivos |
| `--verbose` | Exibe detalhes das operações |
| `--help` | Mostra a ajuda do programa |

## Exemplos de uso

### Simulação

```bash
./wxt-cpp-001-file-organizer organize --dir="E:\@LIB-C++" --dry-run
```

### Executar organização

```bash
./wxt-cpp-001-file-organizer organize --dir="E:\@LIB-C++"
```

### Exibir detalhes

```bash
./wxt-cpp-001-file-organizer organize --dir="E:\@LIB-C++" --verbose
```

### Ajuda

```bash
./wxt-cpp-001-file-organizer --help
```

## Categorias padrão

| Categoria | Extensões de exemplo |
|---|---|
| Documentos | `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf` |
| Imagens | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp` |
| Vídeos | `.mp4`, `.avi`, `.mkv`, `.mov` |
| Músicas | `.mp3`, `.wav`, `.flac`, `.aac` |
| Compactados | `.zip`, `.rar`, `.7z`, `.tar`, `.gz` |
| Outros | Demais extensões |

A estrutura resultante segue a ideia:

```text
Diretório
├── Documentos
├── Imagens
├── Vídeos
├── Músicas
├── Compactados
└── Outros
```

## Segurança — dry-run

Antes de executar a organização real, pode-se utilizar:

```text
--dry-run
```

Nesse modo, o programa apenas informa quais operações seriam realizadas, sem mover os arquivos.

Isso permite revisar o resultado antes da alteração efetiva do diretório.

## Compilação — Linux

Ubuntu 24.04:

```bash
g++ -std=c++17 -O2 wxt-cpp-001-file-organizer.cpp -o file-organizer
```

## Compilação — Windows

Visual Studio 2022:

```text
cl /std:c++17 /O2 ^
   wxt-cpp-001-file-organizer.cpp ^
   /Fe:file-organizer.exe
```

## Benefícios

O File Organizer ajuda a:

- manter arquivos organizados;
- economizar tempo;
- reduzir desordem e duplicação;
- padronizar diretórios;
- organizar ambientes de desenvolvimento;
- automatizar tarefas repetitivas de classificação.

## Tecnologia

```text
Linguagem : C++17
Plataforma: Linux / Windows
Tipo      : Aplicação de linha de comando
Projeto   : WX-TOOLS 001
```

## Filosofia

**Organização transforma caos em produtividade.**

O WX-TOOLS 001 inaugura a coleção com uma ferramenta simples e prática para automatizar a organização de arquivos.

---

**POLYDEV | WX-TOOLS | C++ | 001 — File Organizer**  
*Pequenas ferramentas. Grandes resultados.*
