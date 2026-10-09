# POLYDEV | WX-TOOLS | 033 — SQL Restore & Recovery Explorer

**Versão:** 1.0.0  
**Linguagem:** C++17  
**Plataforma homologada:** Windows / Visual Studio 2022  
**Banco de testes:** SQL Server 2025, instância `.\WSRV25`, banco `WX_RECOVERY_LAB`  
**Fonte:** `wxt-cpp-033-sql-restore-recovery-explorer.cpp`  
**Executável:** `wxt-cpp-033-sql-restore-recovery-explorer.exe`  
**Banner:** `wxt-cpp-033-sql-restore-recovery-explorer.png`

## Objetivo

Utilitário de linha de comando em C++17 e ODBC para examinar o histórico e os metadados de backups do SQL Server, solicitar a verificação de um arquivo de backup e gerar um **modelo ilustrativo** de restauração, sem executar `RESTORE DATABASE`.

## Comandos

| Comando | Finalidade |
|---|---|
| `history` | Consulta o histórico de backups no `msdb`, com tipos FULL/DIFF/LOG, datas, LSNs, posição, tamanho e dispositivo. |
| `header` | Executa a inspeção do cabeçalho de um backup (`RESTORE HEADERONLY`). |
| `files` | Lista arquivos lógicos e físicos contidos no backup (`RESTORE FILELISTONLY`). |
| `verify` | Solicita ao SQL Server `RESTORE VERIFYONLY`. |
| `plan` | Exibe um roteiro **ilustrativo e não executado** com comandos de inspeção e um exemplo comentado de restauração. |

## Requisitos

- Windows e Visual Studio 2022 com suporte a C++17.
- Biblioteca ODBC do Windows (`odbc32.lib`) e driver ODBC compatível com SQL Server.
- Acesso autorizado à instância SQL Server e permissões necessárias aos comandos consultados.
- Para `header`, `files`, `verify` e `plan`, o caminho indicado em `--file` deve ser acessível **ao serviço do SQL Server**, não apenas ao computador cliente.

## Compilação

No projeto do Visual Studio 2022, configure C++17 e gere o executável com o nome `wxt-cpp-033-sql-restore-recovery-explorer.exe` no diretório `E:\@LIB-C++\bin`. A ligação com `odbc32.lib` é necessária.

## Exemplos no PowerShell

```powershell
& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" --version

& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" history --server ".\WSRV25" --db "WX_RECOVERY_LAB"

& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" header --server ".\WSRV25" --file "E:\@LIB-C++\WX_RECOVERY_LAB_FULL.bak"

& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" files --server ".\WSRV25" --file "E:\@LIB-C++\WX_RECOVERY_LAB_FULL.bak"

& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" verify --server ".\WSRV25" --file "E:\@LIB-C++\WX_RECOVERY_LAB_FULL.bak"

& "E:\@LIB-C++\bin\wxt-cpp-033-sql-restore-recovery-explorer.exe" plan --server ".\WSRV25" --db "WX_RECOVERY_LAB" --file "E:\@LIB-C++\WX_RECOVERY_LAB_FULL.bak"
```

## Segurança e limites

- O utilitário **não executa a restauração** do banco de dados.
- O comando `verify` executa uma verificação solicitada ao SQL Server; o sucesso de `RESTORE VERIFYONLY` **não garante** que uma restauração real será concluída nem substitui testes periódicos de recuperação.
- O comando `plan` **não determina automaticamente** uma cadeia FULL → DIFF → LOG, nem valida a compatibilidade dos LSNs. O exemplo gerado deve ser revisado e completado manualmente antes de qualquer utilização fora da ferramenta.
- Caminhos `MOVE`, nomes lógicos, banco de destino, `NORECOVERY` e `RECOVERY` precisam ser conferidos antes de uma restauração real.

## Homologação funcional — 09/10/2026

Testes informados no ambiente `WX_RECOVERY_LAB`:

| Teste | Resultado |
|---|---|
| `history` | Listou backups FULL, LOG e DIFF e seus metadados. |
| `header` | Exibiu cabeçalho do backup FULL. |
| `files` | Identificou os arquivos lógicos de dados e log. |
| `verify` | Concluiu sem erro SQL reportado pelo programa. |
| `plan` | Gerou roteiro ilustrativo, sem execução. |

**Situação:** testes funcionais concluídos no ambiente informado; documentação não representa teste de restauração efetiva.
