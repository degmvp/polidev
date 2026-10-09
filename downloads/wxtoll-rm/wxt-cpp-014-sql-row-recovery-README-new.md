# POLYDEV | WX-TOOLS | C++ | 014 — SQL Row Recovery

## Visão geral

O **SQL Row Recovery** é uma ferramenta em C++ da coleção **POLYDEV WX-TOOLS** para inspeção e recuperação de registros diretamente de arquivos **MDF/NDF do SQL Server**, interpretando a estrutura física das páginas e das linhas.

A ferramenta é especialmente útil quando tabelas estão corrompidas ou inacessíveis pelo mecanismo normal de consulta, mas os dados ainda permanecem fisicamente no arquivo.

Sua operação é **somente leitura (READ-ONLY)**.

## Principais recursos

- Acesso direto aos arquivos MDF/NDF.
- Leitura física de páginas de 8 KB do SQL Server.
- Identificação do tipo de página.
- Identificação de slots e offsets de registros.
- Inspeção da estrutura interna das rows.
- Decodificação de colunas fixas e variáveis.
- Suporte a tipos comuns, incluindo `INT`, `BIGINT`, `VARCHAR`, `CHAR`, `DECIMAL` e `DATETIME2`.
- Exibição de bytes brutos do registro.
- Análise de bitmap de NULLs e offsets variáveis.
- Operação sem utilizar o mecanismo de consulta do SQL Server.
- Funcionamento com bancos OFFLINE.
- Interface via linha de comando.
- Sem dependências externas, utilizando C++17.

## Uso básico

```text
wxt-cpp-014-sql-row-recovery.exe row <arquivo.mdf> <pagina> <slot>
```

## Exemplo

```text
wxt-cpp-014-sql-row-recovery.exe row ^
  "E:\ZZW-2025\MSSQL17.WSRV25\MSSQL\DATA\WX_RECOVERY_LAB.mdf" 248 1
```

## Exemplo de inspeção física

```text
POLYDEV | WX-TOOLS - SQL ROW RECOVERY
Phase 2: physical row inspector (READ-ONLY)

Physical page : 248
SQL Page ID   : (1:248)
Page type     : 1 (DATA)
Slot count    : 39
Selected slot : 1
Row offset    : 298
Status Bits A : 0x30
Status Bits B : 0x00
Fixed end     : 59 bytes from row start
Column count  : 7
NULL bitmap   : 1 byte(s)
NULL columns  : none
Variable cols : 3
Var endings   : 81, 100, 202
Row boundary  : 500
Header parsed : through page offset 368
```

## Exemplo de registro recuperado

```text
RECOVERED ROW - WX_RECOVERY_LAB.dbo.DadosTeste

Id           : 2
Codigo       : WX-00000002
Nome         : Registro de teste 2
Descricao    : POLYDEV WX-TOOLS Recovery Lab - registro físico
               número 2 - conteúdo criado para testes de recuperação.
Valor        : 2.74
DataCadastro : 2026-01-01 00:00:02
Marcador     : C81E728D9D4C2F636F067F89CC14862C
```

O resultado demonstra que a estrutura da row pode ser localizada e interpretada diretamente do MDF/NDF sem utilizar o mecanismo de consulta do SQL Server.

## Cenários de aplicação

O SQL Row Recovery pode auxiliar em:

- tabelas corrompidas ou inacessíveis;
- recuperação de registros específicos;
- análise forense de dados;
- validação de integridade em ambiente de teste;
- extração de informações sem iniciar o SQL Server;
- diagnóstico de estruturas físicas de registros.

## Requisitos

- C++17.
- Visual Studio 2022 ou superior no Windows, ou compilador C++17 compatível.
- Windows ou Linux.
- Nenhuma biblioteca externa.

## Compilação — Visual Studio

```text
cl /std:c++17 /O2 /EHsc /utf-8 /W4 ^
   wxt-cpp-014-sql-row-recovery.cpp ^
   /Fe:wxt-cpp-014-sql-row-recovery.exe
```

## Segurança

A ferramenta foi projetada exclusivamente para **análise e recuperação**.

Ela não modifica o MDF/NDF e deve ser utilizada sobre uma cópia do arquivo de dados sempre que possível, especialmente em cenários reais de corrupção ou recuperação.

O uso deve ocorrer em ambiente de teste ou com autorização sobre os dados analisados.

## Posição na suíte de recuperação

O WX-TOOLS 014 representa a etapa de inspeção de registros da suíte:

```text
013 — SQL Page Recovery
014 — SQL Row Recovery
015 — SQL Table Recovery
016 — SQL MDF Damage Mapper
```

Enquanto o 013 trabalha no nível de página, o 014 avança para a estrutura física da **row**, permitindo interpretar e reconstruir seus campos.

---

**POLYDEV | WX-TOOLS | C++**  
*Dados podem ser recuperados. O importante é ter as ferramentas certas.*
