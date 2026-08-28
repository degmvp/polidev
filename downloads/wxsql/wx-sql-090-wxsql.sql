/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat25.sql
Título..........: Index Series - Disabled Indexes
Procedure.......: poly_cat_DisabledIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar índices desabilitados. Índices desabilitados ocupam espaço em disco mas não são 
mantidos pelo SQL Server. Se não forem reabilitados ou dropados, são puro lixo.

Aplicações:
- Limpeza de ambiente
- Auditoria pós-migração de dados massivos (onde índices são desabilitados)
- Recuperação de espaço

Catálogo utilizado:
sys.indexes
sys.tables
sys.schemas

Execução:
EXEC poly_cat_DisabledIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_DisabledIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        i.type_desc AS IndexType
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i.is_disabled = 1
    ORDER BY s.name, t.name, i.name;
END;
GO

EXEC poly_cat_DisabledIndexes;
GO
