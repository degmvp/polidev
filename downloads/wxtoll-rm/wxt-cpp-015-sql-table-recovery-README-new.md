# POLYDEV | WX-TOOLS | C++ | 015 — SQL Table Recovery

## Visão geral

O **SQL Table Recovery** é a terceira etapa da suíte de recuperação física POLYDEV WX-TOOLS, após as ferramentas 013 e 014.

O utilitário percorre páginas **DATA** de arquivos **MDF/NDF**, examina os slots, decodifica os registros pertencentes à tabela alvo e exporta os dados recuperados para **CSV**.

O processamento é realizado diretamente sobre o arquivo físico do banco, em modo **somente leitura (READ-ONLY)**, sem necessidade de o SQL Server estar em execução.

## Principais recursos

- Varredura das páginas DATA do MDF/NDF.
- Identificação e leitura dos slots das páginas.
- Reconstrução dos registros a partir dos bytes armazenados.
- Decodificação e validação dos campos da tabela.
- Filtragem de registros inválidos ou pertencentes a outras estruturas.
- Exportação dos registros recuperados para CSV.
- Operação somente leitura.
- Possibilidade de analisar o arquivo completo ou um intervalo de páginas.
- Uso em recuperação, análise forense, auditoria e diagnóstico de corrupção.

## Fluxo de funcionamento

```text
Arquivo MDF/NDF
    |
    v
Percorrer páginas
    |
    v
Identificar páginas DATA
    |
    v
Ler todos os slots da página
    |
    v
Decodificar e validar o registro
    |
    v
Registro válido?
  Sim -> exporta para CSV
  Não -> descarta
    |
    v
Arquivo CSV com registros recuperados
```

## Sintaxe básica

```text
wxt-cpp-015-sql-table-recovery.exe harvest
    <arquivo_mdf>
    <arquivo_csv_saida>
    [pagina_inicio] [pagina_fim]
```

## Exemplo — varredura completa

```text
wxt-cpp-015-sql-table-recovery.exe harvest ^
  "E:\ZZW-2025\MSSQL17.WSRV25\MSSQL\DATA\WX_RECOVERY_LAB.mdf" ^
  "E:\@LIB-C++\bin\recovered-015-full.csv"
```

## Exemplo — intervalo de páginas

```text
wxt-cpp-015-sql-table-recovery.exe harvest ^
  "E:\ZZW-2025\MSSQL17.WSRV25\MSSQL\DATA\WX_RECOVERY_LAB.mdf" ^
  "E:\@LIB-C++\bin\recovered-015.csv" 248 248
```

## Saída de exemplo

```text
============================================================
 POLYDEV | WX-TOOLS - SQL TABLE RECOVERY
 Phase 3: DATA page row harvester (READ-ONLY)
============================================================

RECOVERED page 248 slot 0  Id=1 Codigo=WX-00000001
RECOVERED page 248 slot 1  Id=2 Codigo=WX-00000002
RECOVERED page 248 slot 2  Id=3 Codigo=WX-00000003
...

Rows recovered : 100000
Rows rejected  : 14291
Output CSV     : E:\@LIB-C++\bin\recovered-015-full.csv

RESULT: recovery harvest completed successfully.
```

## Resultado da homologação

| Métrica | Resultado |
|---|---:|
| Arquivo | WX_RECOVERY_LAB.mdf |
| Páginas lidas | 9.216 |
| Páginas DATA | 2.836 |
| Slots examinados | 114.291 |
| Registros recuperados | **100.000** |
| Registros rejeitados | 14.291 |
| Arquivo CSV | recovered-015-full.csv |
| Status | **HOMOLOGADO** |

O teste recuperou **100.000 registros com sucesso**.

## Requisitos

- Windows ou Linux.
- Compilador com suporte a **C++17**.
- Nenhuma dependência externa.
- Acesso somente leitura ao arquivo MDF/NDF.
- Conhecimento da estrutura da tabela alvo para a decodificação correta.

## Aplicações

O SQL Table Recovery é útil para:

- recuperação de tabelas em bancos danificados;
- análise forense de dados;
- extração de registros inacessíveis pelo SQL Server;
- auditoria e diagnóstico de corrupção;
- cenários de desastre nos quais os métodos tradicionais não conseguem acessar os dados.

## Segurança

A ferramenta trabalha em **READ-ONLY** e não altera o MDF/NDF em nenhum momento.

Para operações reais de recuperação, recomenda-se trabalhar sobre uma cópia do arquivo físico, mantendo o original preservado.

## Suíte de recuperação

O WX-TOOLS 015 integra a sequência de ferramentas de recuperação física:

```text
013 — SQL Page Recovery
014 — SQL Row Recovery
015 — SQL Table Recovery
```

Cada etapa amplia o nível de recuperação: da página física para os registros e, em seguida, para a reconstrução de uma tabela completa.

---

**POLYDEV | WX-TOOLS | C++**  
*Pequenos utilitários, grandes soluções.*
