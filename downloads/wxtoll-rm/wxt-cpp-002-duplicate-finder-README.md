# POLYDEV | WX-TOOLS | C++ | 002 — Duplicate File Finder

## Visão geral

O **Duplicate File Finder** é um utilitário de linha de comando em **C++17** para localizar arquivos duplicados dentro de um diretório de forma rápida, segura e eficiente.

A ferramenta trabalha em modo somente leitura: não apaga nem modifica arquivos. A detecção é otimizada agrupando inicialmente os arquivos por tamanho e calculando hash apenas para os candidatos a duplicação.

## Principais recursos

- Varredura recursiva em subdiretórios.
- Agrupamento inicial por tamanho.
- Cálculo de hash somente nos arquivos candidatos.
- Identificação de grupos de duplicados.
- Filtro por tamanho mínimo.
- Filtro por extensão.
- Exportação opcional para JSON.
- Operação somente leitura.
- Logs e estatísticas detalhadas.
- Interface simples via linha de comando.
- Código C++17 sem dependências externas.
- Compatível com Linux e Windows.

## Como funciona

```text
1. Varredura recursiva no diretório
2. Agrupamento inicial por tamanho
3. Cálculo de hash apenas nos candidatos
4. Identificação dos arquivos duplicados
5. Exibição dos resultados
6. Exportação opcional para JSON
```

O agrupamento por tamanho evita calcular hash de arquivos que não podem ser duplicados, reduzindo o trabalho necessário durante a análise.

## Comandos principais

```text
wxt-cpp-002 <diretório>
```

Varre o diretório informado procurando arquivos duplicados.

### Tamanho mínimo

```text
--min-size <valor>
```

Define o tamanho mínimo dos arquivos analisados.

Exemplos:

```text
1MB
500KB
2GB
```

### Filtro por extensão

```text
--extension <ext>
```

Exemplos:

```text
--extension .pdf
--extension .jpg
```

### Exportação JSON

```text
--export <arquivo.json>
```

Exporta os resultados para um arquivo JSON.

### Ajuda

```text
--help
```

## Exemplos de uso

### Varredura simples

```bash
./wxt-cpp-002-duplicate-finder /home/user/Downloads
```

### Arquivos com no mínimo 1 MB

```bash
./wxt-cpp-002-duplicate-finder /home/user/Downloads --min-size 1MB
```

### Somente arquivos PDF

```bash
./wxt-cpp-002-duplicate-finder /home/user/Downloads --extension .pdf
```

### Exportar resultados

```bash
./wxt-cpp-002-duplicate-finder /home/user/Downloads --export duplicados.json
```

### Ajuda

```bash
./wxt-cpp-002-duplicate-finder --help
```

## Informações exibidas

Ao final da execução, o programa pode apresentar:

- total de arquivos varridos;
- total de candidatos analisados;
- total de arquivos duplicados;
- total de grupos de duplicados;
- espaço potencialmente recuperável;
- erros de leitura, caso existam.

## Tipos de arquivos

A ferramenta pode trabalhar com qualquer extensão, incluindo:

| Categoria | Exemplos |
|---|---|
| Documentos | `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf` |
| Imagens | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp` |
| Vídeos | `.mp4`, `.avi`, `.mkv`, `.mov` |
| Músicas | `.mp3`, `.wav`, `.flac`, `.aac` |
| Compactados | `.zip`, `.rar`, `.7z`, `.tar`, `.gz` |
| Outros | qualquer extensão |

## Compilação — Linux

Ubuntu 24.04:

```bash
g++ -std=c++17 -O2 wxt-cpp-002-duplicate-finder.cpp -o duplicate-finder
```

## Compilação — Windows

Visual Studio 2022:

```text
cl /std:c++17 /O2 ^
   wxt-cpp-002-duplicate-finder.cpp ^
   /Fe:duplicate-finder.exe
```

## Benefícios

O Duplicate File Finder ajuda a:

- recuperar espaço em disco;
- evitar arquivos redundantes;
- organizar dados;
- localizar cópias desnecessárias;
- analisar grandes árvores de diretórios sem modificar os arquivos.

## Segurança

A ferramenta é **somente leitura**.

Ela identifica duplicados e calcula o espaço potencialmente recuperável, mas não remove arquivos automaticamente.

---

**POLYDEV | WX-TOOLS | C++ | 002 — Duplicate File Finder**  
*Encontre duplicados, recupere espaço, mantenha sua organização.*
