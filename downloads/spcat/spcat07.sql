/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat07.sql
Título..........: Catalog Explorer - List Indexes
Procedure.......: poly_cat_ListIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todos os índices existentes nas tabelas do banco atual.

Aplicações:
- Inventário de índices
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.indexes
sys.tables

Execução:
EXEC poly_cat_ListIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListIndexes
AS
BEGIN
SET NOCOUNT ON;

SELECT
    t.name AS TableName,
    i.index_id AS IndexID,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.is_primary_key AS IsPrimaryKey
FROM sys.indexes i
     INNER JOIN sys.tables t
        ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
ORDER BY
    t.name,
    i.name;

END;
GO

EXEC poly_cat_ListIndexes;
GO