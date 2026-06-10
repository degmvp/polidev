/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat28.sql
Título..........: Index Series - Estimated Index Key Size (900 Byte Warning)
Procedure.......: poly_cat_IndexKeySizeWarning
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Calcular o tamanho estimado da chave de cada índice. O SQL Server tem um limite rígido de 900 bytes
por chave de índice. Esta SP lista os índices que estão perto ou ultrapassam esse limite teórico,
o que pode causar erros em futuros INSERTs/UPDATEs.

Aplicações:
- Prevenção de erros de runtime (Error 1946 / 8116)
- Análise de impacto de alteração de colunas (ex: aumentar VARCHAR)
- Otimização de chaves compostas

Catálogo utilizado:
sys.indexes
sys.index_columns
sys.columns
sys.tables
sys.schemas

Execução:
EXEC poly_cat_IndexKeySizeWarning;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_IndexKeySizeWarning
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        SUM(CASE WHEN c.max_length = -1 THEN 900 ELSE c.max_length END) AS EstimatedMaxKeySizeBytes,
        CASE 
            WHEN SUM(CASE WHEN c.max_length = -1 THEN 900 ELSE c.max_length END) > 900 THEN 'EXCEEDS LIMIT!'
            WHEN SUM(CASE WHEN c.max_length = -1 THEN 900 ELSE c.max_length END) > 750 THEN 'DANGER ZONE'
            ELSE 'OK' 
        END AS RiskLevel
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE ic.is_included_column = 0
      AND i.type_desc = 'NONCLUSTERED'
    GROUP BY s.name, t.name, i.name
    HAVING SUM(CASE WHEN c.max_length = -1 THEN 900 ELSE c.max_length END) > 750
    ORDER BY EstimatedMaxKeySizeBytes DESC;
END;
GO

EXEC poly_cat_IndexKeySizeWarning;
GO
