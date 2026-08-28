/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat14.sql
Título..........: Catalog Explorer - Missing Foreign Key Indexes
Procedure.......: poly_cat_MissingFKIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar colunas que são Chaves Estrangeiras, mas que não possuem um índice associado, o que pode causar lentidão em JOINs e bloqueios (Locks).

Aplicações:
- Otimização de performance
- Prevenção de deadlocks
- Análise de impacto de relacionamentos

Catálogo utilizado:
sys.foreign_keys
sys.foreign_key_columns
sys.tables
sys.columns
sys.indexes
sys.index_columns

Execução:
EXEC poly_cat_MissingFKIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_MissingFKIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        OBJECT_NAME(fk.parent_object_id) AS TableName,
        COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
        OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
        fk.name AS FKName
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc 
        ON fk.object_id = fkc.constraint_object_id
    WHERE NOT EXISTS (
        -- Verifica se a coluna FK é a primeira coluna de algum índice
        SELECT 1 
        FROM sys.index_columns ic
        INNER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        WHERE ic.object_id = fk.parent_object_id 
          AND ic.column_id = fkc.parent_column_id
          AND ic.key_ordinal = 1 -- Importante: Ser a coluna líder do índice
    )
    ORDER BY TableName, ColumnName;
END;
GO

EXEC poly_cat_MissingFKIndexes;
GO
