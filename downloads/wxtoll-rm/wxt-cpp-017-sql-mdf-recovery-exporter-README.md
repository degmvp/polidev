# POLYDEV | WX-TOOLS | C++ | 017 — SQL MDF Recovery Exporter

## Visão geral

O **SQL MDF Recovery Exporter** é uma ferramenta da coleção **POLYDEV WX-TOOLS**, desenvolvida em **C++17**, para leitura física de arquivos **MDF do SQL Server** e exportação dos registros recuperados para um script **T-SQL**.

A ferramenta trabalha diretamente sobre o arquivo MDF, em modo **somente leitura**, permitindo recuperar dados de uma tabela mesmo sem acesso ao servidor SQL Server original. O arquivo gerado contém comandos `INSERT` que podem ser utilizados para reconstruir os registros em outro banco ou ambiente.

## Principais recursos

- Leitura direta do arquivo MDF do SQL Server.
- Operação somente leitura, sem alteração do arquivo original.
- Extração de dados de tabelas mesmo sem acesso ao servidor.
- Geração de script T-SQL com comandos `INSERT`.
- Suporte a diferentes tipos de dados.
- Preservação dos valores originais, incluindo colunas `IDENTITY`.
- Útil em cenários de corrupção, exclusão acidental ou perda de dados.
- Permite reconstruir os registros recuperados em outro banco.

## Uso

```text
wxt-cpp-017-mdf-exporter.exe \
  --file="C:\SQLDATA\MeuBanco.mdf" \
  --table="dbo.DadosTeste" \
  --output="recovered.sql"
```

## Exemplo de execução

```text
E:\> wxt-cpp-017-mdf-exporter.exe \
  --file="C:\SQLDATA\WX_RECOVERY_LAB.mdf" \
  --table="dbo.DadosTeste" \
  --output="wxt-cpp-017-recovered-full.sql"

[TABLE] dbo.DadosTeste
[ROWS ] 100000
[FILE ] wxt-cpp-017-recovered-full.sql
[DONE ] Export concluido com sucesso!
```

## Exemplo do T-SQL gerado

```sql
-- Script gerado pelo WX-TOOLS 017
-- Tabela: dbo.DadosTeste
-- Registros: 100000

BEGIN TRANSACTION;
SET IDENTITY_INSERT dbo.DadosTeste_Recovery ON;

INSERT INTO dbo.DadosTeste_Recovery
    (Id, Codigo, Nome, Descricao, Valor, DataCadastro, Marcador)
VALUES
    (1, 'WX-00000001', 'Registro 1', 'Teste...', 1.37,
     '2026-01-01 00:00:01', 'A');

-- demais registros...

SET IDENTITY_INSERT dbo.DadosTeste_Recovery OFF;
COMMIT TRANSACTION;
```

> Durante testes de recuperação, o `COMMIT TRANSACTION` pode ser substituído por `ROLLBACK` para validar o resultado sem tornar as alterações permanentes.

## Ambiente de homologação

| Item | Valor |
|---|---|
| SQL Server | 2025 Developer |
| Banco | WX_RECOVERY_LAB |
| Arquivo MDF | 72.00 MiB — 9.216 páginas |
| Tabela | dbo.DadosTeste |
| Registros | 100.000 |
| Resultado | 100000 / 1 / 100000 |
| Status | Homologado |

No laboratório de recuperação, os **100.000 registros** foram recuperados com sucesso.

## Compilação no Windows

Exemplo com o compilador Microsoft C++:

```text
cl /std:c++17 /O2 /EHsc /utf-8 /W4 ^
   wxt-cpp-017-mdf-recovery.cpp ^
   /Fe:wxt-cpp-017-mdf-exporter.exe
```

## Segurança

O utilitário foi projetado para operar sobre o MDF em **modo somente leitura**. Para trabalhos de recuperação, recomenda-se utilizar uma **cópia offline do arquivo MDF**, preservando o arquivo original.

O script T-SQL produzido deve ser revisado antes da execução definitiva, especialmente quanto ao banco de destino, tabela, `IDENTITY_INSERT` e controle de transação.

## Caso de uso

O WX-TOOLS 017 é indicado para situações em que registros precisam ser recuperados diretamente do MDF, como corrupção do banco, exclusão acidental ou indisponibilidade de um backup adequado.

A recuperação física permite extrair os dados e gerar um script independente para reconstrução em outro ambiente SQL Server.

---

**POLYDEV | WX-TOOLS | C++**  
*Tools for a Better Tomorrow*
