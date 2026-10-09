# POLYDEV | WX-TOOLS | C++ | 010 — File Age Analyzer

## Visão geral

O **File Age Analyzer** é uma ferramenta C++ da coleção **POLYDEV WX-TOOLS** para analisar a idade dos arquivos com base na data de modificação.

O utilitário contabiliza a quantidade e o espaço ocupado por diferentes faixas de tempo, apresenta detalhamento por diretório e identifica os maiores arquivos encontrados.

Toda a análise é realizada em **modo somente leitura**: nenhum arquivo é excluído ou modificado.

## Principais recursos

- Análise da idade dos arquivos pela data de modificação.
- Contagem de arquivos por faixa de tempo.
- Cálculo do espaço ocupado por cada faixa.
- Detalhamento por diretório.
- Listagem dos maiores arquivos.
- Controle de profundidade da varredura.
- Limite configurável para o ranking de maiores arquivos.
- Saída opcional em JSON.
- Operação somente leitura.

## Faixas de idade padrão

| Faixa | Classificação |
|---|---|
| `< 30 dias` | Arquivos muito recentes |
| `30–90 dias` | Arquivos recentes |
| `90 dias–1 ano` | Arquivos intermediários |
| `1–3 anos` | Arquivos antigos |
| `> 3 anos` | Arquivos muito antigos |

## Sintaxe

```text
wxt-cpp-010-file-age-analyzer.exe scan <caminho> [opções]
```

## Exemplos

### Pasta atual

```text
wxt-cpp-010-file-age-analyzer.exe scan .
```

### Pasta específica

```text
wxt-cpp-010-file-age-analyzer.exe scan "E:\@LIB-C++"
```

### Drive C

```text
wxt-cpp-010-file-age-analyzer.exe scan C:\ --depth 1 --top 20
```

### Ajuda

```text
wxt-cpp-010-file-age-analyzer.exe --help
```

## Opções principais

| Opção | Função |
|---|---|
| `--depth N` | Define o nível de profundidade; `0` = ilimitado |
| `--top N` | Mostra os N maiores arquivos |
| `--json` | Produz saída em formato JSON |
| `--help` | Exibe a ajuda |

## Exemplo de execução real

```text
E:\@LIB-C++>bin\wxt-cpp-010-file-age-analyzer.exe scan C:\ --depth 1 --top 20

Analisando C:/ ...
File Age Analyzer (somente leitura)
Raiz: C:/
Arquivos: 1.101.708
Total: 163.5 GB
```

### Distribuição por idade

```text
IDADE            ARQUIVOS      TAMANHO      % TAM
--------------------------------------------------
< 30 dias         139.838       49.1 GB      30.0%
30-90 dias        113.399       19.1 GB      11.7%
90 dias-1 ano     165.830       26.9 GB      16.4%
1-3 anos          450.966       41.5 GB      25.4%
> 3 anos          231.675       27.0 GB      16.5%
```

## Detalhamento por diretório

A ferramenta também mostra como o espaço de cada faixa de idade está distribuído pelos diretórios de primeiro nível.

Exemplo:

```text
DIRETORIO          <30d     30d-90d    90d-1a    1a-3a     >3a      TOTAL
-------------------------------------------------------------------------------
Users              11.8 GB   6.80 GB   13.1 GB   15.2 GB   9.81 GB   56.8 GB
Windows            19.7 GB   7.94 GB    4.02 GB  10.2 GB   3.83 GB   45.6 GB
Program Files       5.61 GB   1.91 GB    4.15 GB   6.87 GB   7.31 GB   25.9 GB
Program Files (x86) 6.36 GB 641.9 MB     2.35 GB   5.55 GB   3.51 GB   18.4 GB
ProgramData         5.35 GB   1.78 GB    3.24 GB   3.57 GB   1.73 GB   15.7 GB
```

## Maiores arquivos

Além da idade, o File Age Analyzer permite descobrir arquivos individuais que mais ocupam espaço.

A listagem apresenta informações como:

```text
tamanho | idade | caminho
```

Isso facilita localizar arquivos grandes e antigos que podem ser avaliados para arquivamento, movimentação ou limpeza manual.

## Segurança

O **File Age Analyzer é somente leitura**.

A ferramenta:

- não exclui arquivos;
- não modifica conteúdo;
- não renomeia arquivos;
- não altera timestamps.

Ao final da varredura, o ambiente permanece inalterado.

## Aplicações

O WX-TOOLS 010 pode ajudar a:

- identificar espaço ocupado por arquivos antigos;
- entender o perfil de crescimento do armazenamento;
- localizar arquivos grandes;
- planejar limpeza de disco;
- decidir o que arquivar ou mover;
- analisar diretórios antes de uma manutenção;
- gerar informações para políticas de retenção.

## Objetivo

**Analise o passado. Recupere o presente.**

A proposta da ferramenta é transformar informações de idade e tamanho em decisões práticas para liberar espaço e melhorar a organização do armazenamento.

---

**POLYDEV | WX-TOOLS | C++ | 010 — File Age Analyzer**  
*Código aberto • Utilidades reais • Resultados concretos*
