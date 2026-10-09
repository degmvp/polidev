# POLYDEV | WX-TOOLS | C++ | 013 — SQL Page Recovery

## Visão geral

O **SQL Page Recovery** é a primeira fase da suíte de recuperação física do **POLYDEV WX-TOOLS**.

A ferramenta realiza a leitura direta e offline de arquivos **MDF/NDF do SQL Server**, examinando páginas físicas de 8 KB sem utilizar o mecanismo do SQL Server.

O utilitário foi projetado para operar em modo **100% READ-ONLY**, sendo indicado para diagnóstico, análise forense e preparação de processos de recuperação.

## Principais recursos

- Leitura direta de arquivos MDF/NDF.
- Operação offline, sem necessidade do SQL Server.
- Varredura de todas as páginas físicas do arquivo.
- Interpretação do cabeçalho das páginas.
- Identificação de tipos como `FILE_HEADER`, `DATA`, `INDEX` e outros.
- Extração do slot array dos registros.
- Verificação básica de sanidade dos cabeçalhos.
- Comparação entre identificação física e Page ID armazenado.
- Inspeção hexadecimal do cabeçalho.
- Operação somente leitura.

## Informações do arquivo

No ambiente de homologação, o arquivo analisado apresentou:

```text
File       : WX_RECOVERY_LAB.mdf
Size       : 75497472 bytes (72.00 MiB)
Page size  : 8192 bytes
Full pages : 9216
Remainder  : 0 bytes
```

## Varredura física

A ferramenta pode percorrer o MDF/NDF e produzir um resumo da análise das páginas.

Exemplo do laboratório:

```text
Summary:

Readable pages       : 9216
All-zero pages       : 1830
Sane headers         : 4099
Suspicious headers   : 3287
Page-id matches      : 3091
Page-id mismatches   : 4295
```

Esses números ajudam a localizar regiões que exigem investigação mais detalhada nas fases seguintes da recuperação.

## Inspeção de página

Exemplo de análise da página física 8:

```text
Physical page : 8
Header version: 1
Type          : 1 (DATA)
Type flags    : 0x04
Level         : 0
Flag bits     : 0x0200
Index ID      : 256
Page ID       : (1:8)
Prev page     : (0:0)
Next page     : (0:0)
Object/Alloc  : 10
pminlen       : 16
Slot count    : 98
Free count    : 3284
Free data off.: 4731
Reserved count: 0
Basic sanity  : OK
Page-id match : YES
```

## Slot array

A inspeção também permite localizar os offsets dos registros presentes na página:

```text
Slot      Offset      Status
--------------------------------
0         115         OK
1         2121        OK
2         4662        OK
3         4613        OK
4         3725        OK
...

Slots total : 98
Invalid     : 0
```

O slot array é fundamental para as etapas posteriores, pois permite localizar fisicamente cada registro dentro de uma página DATA.

## Exemplos de uso

### Informações do arquivo

```text
wxt-cpp-013-sql-page-recovery.exe info WX_RECOVERY_LAB.mdf
```

### Varredura completa

```text
wxt-cpp-013-sql-page-recovery.exe scan WX_RECOVERY_LAB.mdf
```

### Inspeção de uma página

```text
wxt-cpp-013-sql-page-recovery.exe page WX_RECOVERY_LAB.mdf 8
```

## Aplicações

O SQL Page Recovery é indicado para:

- diagnóstico de arquivos MDF/NDF;
- análise forense;
- investigação de corrupção física;
- identificação de páginas DATA e INDEX;
- localização de registros através do slot array;
- preparação para recuperação de rows e tabelas;
- estudo da estrutura física do SQL Server.

## Segurança

A ferramenta é **READ-ONLY**.

Nenhuma página é gravada ou modificada durante a análise. Em trabalhos reais de recuperação, recomenda-se utilizar uma cópia offline do MDF/NDF e preservar o arquivo original.

## Suíte de recuperação

O WX-TOOLS 013 inicia a sequência de recuperação física:

```text
013 — SQL Page Recovery
014 — SQL Row Recovery
015 — SQL Table Recovery
016 — SQL MDF Damage Mapper
017 — SQL MDF Recovery Exporter
```

O 013 trabalha no nível mais fundamental: **as páginas físicas do arquivo**. As ferramentas seguintes avançam para registros, tabelas, mapeamento de danos e exportação dos dados recuperados.

---

**POLYDEV | WX-TOOLS | C++**  
*Read. Analyze. Recover.*
