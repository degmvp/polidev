/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat08.sql
Título..........: Catalog Explorer - List Triggers
Procedure.......: poly_cat_ListTriggers
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todos os triggers definidos nas tabelas do banco atual.

Aplicações:
- Inventário de triggers
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.triggers
sys.tables
sys.sql_modules

Execução:
EXEC poly_cat_ListTriggers;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListTriggers
AS
BEGIN
SET NOCOUNT ON;

SELECT
    t.name AS TableName,
    tr.name AS TriggerName,
    tr.is_disabled AS IsDisabled,
    m.definition AS TriggerDefinition
FROM sys.triggers tr
     INNER JOIN sys.tables t
        ON tr.parent_id = t.object_id
     INNER JOIN sys.sql_modules m
        ON tr.object_id = m.object_id
ORDER BY
    t.name,
    tr.name;

END;
GO

EXEC poly_cat_ListTriggers;
GO