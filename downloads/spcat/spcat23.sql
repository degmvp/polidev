/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat23.sql
Título..........: Index Series - Wide Indexes (Too Many Included Columns)
Procedure.......: poly_cat_WideIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar índices que usam excessivamente a cláusula INCLUDE. 
Índices muito "largos" consomem muito disco, memoria (Buffer Pool) e tornam updates lentos.

Aplicações:
- Otimização de I/O e Memória
- Revisão de estratégia de Covering Indexes
- Engenharia reversa de performance

Catálogo utilizado:
sys.indexes
sys.index_columns
sys.tables
sys.schemas

Execução:
EXEC poly_cat_WideIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_WideIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        i.type_desc AS IndexType,
        COUNT(ic.column_id) AS IncludedColumnsCount
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    WHERE ic.is_included_column = 1
      AND i.is_primary_key = 0
    GROUP BY s.name, t.name, i.name, i.type_desc
    HAVING COUNT(ic.column_id) >= 4 -- Limiar configurável (ex: 4 ou mais colunas inclusas)
    ORDER BY IncludedColumnsCount DESC;
END;
GO

EXEC poly_cat_WideIndexes;
GO
