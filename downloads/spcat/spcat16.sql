/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat16.sql
Título..........: Catalog Explorer - Tables and Triggers Mapping
Procedure.......: poly_cat_TablesTriggersMapping
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Mapear quais tabelas possuem gatilhos (triggers), quantos são, e se são do tipo AFTER ou INSTEAD OF.

Aplicações:
- Mapeamento de lógica de negócios oculta
- Auditoria de ações DML
- Documentação de comportamentos não lineares

Catálogo utilizado:
sys.tables
sys.triggers
sys.schemas

Execução:
EXEC poly_cat_TablesTriggersMapping;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_TablesTriggersMapping
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        COUNT(tr.object_id) AS TriggerCount,
        STRING_AGG(tr.name, ', ') AS TriggerNames,
        STRING_AGG(tr.type_desc, ', ') AS TriggerTypes
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.triggers tr ON t.object_id = tr.parent_id
    GROUP BY s.name, t.name
    ORDER BY TriggerCount DESC, s.name, t.name;
END;
GO

EXEC poly_cat_TablesTriggersMapping;
GO

