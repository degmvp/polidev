/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat27.sql
Título..........: Index Series - Lock Escalation Blockers
Procedure.......: poly_cat_IndexLockBehavior
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar índices que tiveram seu comportamento de bloqueio alterado (ALLOW_ROW_LOCKS = OFF ou 
ALLOW_PAGE_LOCKS = OFF). Isso força o SQL Server a usar bloqueios no nível do objeto (Table Lock),
causando enormes problemas de concorrência e deadlocks em ambientes OLTP.

Aplicações:
- Resolução de problemas de Deadlock e Concorrência
- Revisão de "gambiarras" de performance antigas
- Auditoria de bloqueios

Catálogo utilizado:
sys.indexes
sys.tables
sys.schemas

Execução:
EXEC poly_cat_IndexLockBehavior;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_IndexLockBehavior
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        CASE WHEN i.allow_row_locks = 0 THEN 'ROW_LOCKS_OFF' ELSE 'OK' END AS RowLockStatus,
        CASE WHEN i.allow_page_locks = 0 THEN 'PAGE_LOCKS_OFF' ELSE 'OK' END AS PageLockStatus
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i.allow_row_locks = 0 OR i.allow_page_locks = 0
    ORDER BY s.name, t.name, i.name;
END;
GO

EXEC poly_cat_IndexLockBehavior;
GO
