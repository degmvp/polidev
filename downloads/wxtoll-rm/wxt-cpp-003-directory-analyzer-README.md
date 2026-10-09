# POLYDEV | WX-TOOLS | C++ | 003 — Directory Analyzer

## Visão geral

O **Directory Analyzer** é um utilitário CLI em C++17 para analisar recursivamente o conteúdo de um diretório, sem modificar os arquivos. Os resultados ajudam a identificar consumo de espaço, arquivos vazios e distribuição por extensão.

**Fonte:** `wxt-cpp-003-directory-analyzer.cpp`  
**Banner:** `wxt-cpp-003-directory-analyzer.png`  
**Modo:** somente leitura (SAFE MODE).

## Funcionalidades

- Contagem de arquivos e subdiretórios.
- Soma do espaço ocupado pelos arquivos encontrados.
- Identificação de arquivos de tamanho zero.
- Contagem de links simbólicos ignorados e erros de leitura.
- Listagem dos maiores arquivos, ordenados por tamanho.
- Distribuição de arquivos e espaço por extensão.
- Listagem dos subdiretórios que mais ocupam espaço.
- Opção `--top N` para limitar os rankings (padrão: 10).

## Requisitos e compilação

Compilador com suporte a C++17 e biblioteca `std::filesystem`.

```bash
g++ -std=c++17 -O2 -Wall -Wextra wxt-cpp-003-directory-analyzer.cpp -o wxt-cpp-003-directory-analyzer
```

## Execução

```bash
./wxt-cpp-003-directory-analyzer --help
./wxt-cpp-003-directory-analyzer /home/degsu/polydev_lab
./wxt-cpp-003-directory-analyzer /home/degsu/polydev_lab --top 15
```

Uso geral:

```text
wxt-cpp-003-directory-analyzer <diretorio> [--top N]
```

## Relatórios apresentados

1. **Resumo:** caminho analisado, arquivos, diretórios, tamanho total, arquivos vazios, links simbólicos ignorados e erros.
2. **Maiores arquivos:** tamanho e caminho relativo.
3. **Distribuição por extensão:** quantidade e espaço por extensão, incluindo arquivos sem extensão.
4. **Diretórios que mais ocupam espaço:** classificação dos subdiretórios por bytes acumulados.

## Segurança e limitações

- Não move, renomeia, altera nem exclui arquivos.
- Ignora links simbólicos para evitar ciclos de navegação.
- Registra erros encontrados durante a varredura; permissões podem impedir a leitura de parte da árvore.
- Os valores de tamanho correspondem aos arquivos acessíveis analisados, não necessariamente ao uso físico alocado em disco.
- A ferramenta não oferece opção de exportação em JSON ou CSV no fonte fornecido.

---

**POLYDEV | WX-TOOLS | C++ | 003 — Directory Analyzer**
