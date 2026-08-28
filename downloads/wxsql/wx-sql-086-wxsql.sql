/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat21.sql
Título..........: Index Series - Overlapping / Redundant Indexes
Procedure.......: poly_cat_OverlappingIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar índices redundantes ou sobrepostos na mesma tabela. 
Ex: Um índice na coluna [A] e outro em [A, B]. O primeiro é desnecessário.

Aplicações:
- Otimização de espaço em disco (reduzir tamanho do banco)
- Melhoria de performance de INSERT/UPDATE (menos índices para atualizar)
- Limpeza de legado

Catálogo utilizado:
sys.indexes
sys.index_columns
sys.tables
sys.schemas

Execução:
EXEC poly_cat_OverlappingIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_OverlappingIndexes
AS
BEGIN
    SET NOCOUNT ON;

    WITH IndexKeys AS (
        SELECT 
            ic.object_id,
            ic.index_id,
            STRING_AGG(CAST(ic.column_id AS VARCHAR(10)), ',') WITHIN GROUP (ORDER BY ic.key_ordinal) AS KeyCols
        FROM sys.index_columns ic
        WHERE ic.is_included_column = 0
        GROUP BY ic.object_id, ic.index_id
    )
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i1.name AS RedundantIndex,
        i2.name AS CoveringIndex,
        i1.type_desc AS RedundantType
    FROM IndexKeys iks1
    INNER JOIN IndexKeys iks2 
        ON iks1.object_id = iks2.object_id 
        AND iks1.KeyCols = LEFT(iks2.KeyCols, LEN(iks1.KeyCols))
        AND iks1.index_id <> iks2.index_id
    INNER JOIN sys.indexes i1 ON iks1.object_id = i1.object_id AND iks1.index_id = i1.index_id
    INNER JOIN sys.indexes i2 ON iks2.object_id = i2.object_id AND iks2.index_id = i2.index_id
    INNER JOIN sys.tables t ON iks1.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i1.is_primary_key = 0 AND i1.is_unique_constraint = 0
    ORDER BY t.name, i1.name;
END;
GO

EXEC poly_cat_OverlappingIndexes;
GO
