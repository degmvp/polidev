# POLYDEV | WX-TOOLS | C++ | 008 — Driftwatch

## Visão geral

O **Driftwatch** é um monitor de crescimento de disco baseado em snapshots. Ele registra o estado do sistema de arquivos e, em uma execução posterior, compara o estado atual com o snapshot anterior para mostrar **o que cresceu, quanto cresceu e onde**.

A ferramenta foi criada para tornar visível o crescimento gradual provocado por arquivos, logs, downloads, caches e outros dados que podem consumir espaço sem serem percebidos.

## Objetivo

Acompanhar o crescimento do uso de disco ao longo do tempo, comparando snapshots e identificando exatamente o que mudou.

## Principais recursos

- Criação de snapshots do sistema de arquivos.
- Comparação entre snapshots (`diff`).
- Identificação dos diretórios que mais cresceram.
- Listagem dos arquivos que mais aumentaram.
- Detecção de arquivos novos e removidos.
- Filtro por tamanho mínimo, por exemplo `>= 4 MiB`.
- Saída formatada e de fácil leitura.
- Sem dependências externas.
- Pode analisar um disco inteiro ou diretórios específicos.

## Uso

```text
driftwatch.exe <comando> [parâmetros]
```

### Comandos

```text
snap <diretório>       Cria um snapshot
diff <snapshot> [dir]  Compara o snapshot com o estado atual
```

## Criando um snapshot

Exemplo:

```text
E:\@LIB-C++\bin>driftwatch.exe snap C:\
```

Saída:

```text
Snapshot gravado com sucesso

Arquivo:      driftwatch-c-20260911-093859.dwsnap
Raiz:         C:\
Criado em:    2026-09-11T12:41:43Z
Total:        162 GiB em 1.101.701 arquivos (295.947 diretórios)
Rastreados:   5.464 arquivos >= 4.0 MiB
Exclusões:    -
```

A ferramenta também apresenta os maiores diretórios encontrados, permitindo uma visão imediata da distribuição do espaço.

## Comparando com um snapshot

Exemplo:

```text
E:\@LIB-C++\bin>driftwatch.exe diff driftwatch-e-lib-c-20260911-092827.dwsnap
```

O Driftwatch varre o estado atual e compara os resultados com o snapshot armazenado.

Exemplo de resumo:

```text
Snapshot:    driftwatch-e-lib-c-20260911-092827.dwsnap
Raiz:        E:\@LIB-C++
Antes:       843 MiB em 10 arquivos (2 diretórios)
Agora:       843 MiB em 11 arquivos (2 diretórios)
Crescimento: +457 B (+0.00%)
```

## Diretórios que mais cresceram

A comparação destaca as áreas responsáveis pela mudança:

```text
dTOTAL     dPROPRIO     dARQS     DIRETORIO
+457 B     +457 B       +1        bin
+457 B     +0 B         +1        <raiz>
```

Isso permite localizar rapidamente onde ocorreu a variação.

## Problema que resolve

Com o tempo, arquivos temporários, logs, downloads, caches e dados de aplicações podem ocupar quantidades significativas de espaço.

O Driftwatch permite responder perguntas como:

- Qual diretório cresceu?
- Quanto ele cresceu?
- Quais arquivos são responsáveis?
- Surgiram arquivos novos?
- Algum arquivo foi removido?
- O crescimento está concentrado em uma pasta específica?

## Dicas de utilização

- Execute snapshots regularmente: diariamente, semanalmente ou conforme a necessidade.
- Utilize `--min-file-size` para concentrar a análise nos arquivos grandes.
- O monitoramento pode ser feito sobre uma pasta específica ou sobre todo o disco.
- Use os resultados para identificar diretórios candidatos a limpeza, arquivamento ou movimentação.
- Guarde snapshots de períodos diferentes para acompanhar a evolução do armazenamento.

## Aplicações

O WX-TOOLS 008 pode ser utilizado para:

- acompanhamento de crescimento de disco;
- investigação de consumo inesperado de espaço;
- monitoramento de logs;
- análise de caches;
- acompanhamento de diretórios de desenvolvimento;
- planejamento de limpeza;
- identificação de arquivos e pastas que mudaram entre períodos.

## Resultado

O Driftwatch fornece uma visão objetiva de como o uso de disco está evoluindo.

Em vez de apenas mostrar quanto espaço está ocupado agora, ele permite saber **o que cresceu, quanto cresceu e onde**, facilitando limpeza, organização e tomada de decisões.

---

**POLYDEV | WX-TOOLS | C++ | 008 — Driftwatch**  
*Pequenas ações hoje evitam grandes problemas amanhã.*
