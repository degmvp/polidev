/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat22.sql
Título..........: Index Series - Heaps with Non-Clustered Indexes
Procedure.......: poly_cat_HeapsWithNCIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar tabelas HEAP (sem Clustered Index) que possuem índices Non-Clustered.
Isso é um anti-pattern grave, pois os NCs usam RIDs (Row Locators) grandes e fragmentados 
em vez de uma chave de Clustered Index estável.

Aplicações:
- Revisão de modelagem física
- Resolução de problemas de fragmentação extrema em NCs
- Planejamento de criação de PKs/Clustered Keys

Catálogo utilizado:
sys.tables
sys.indexes
sys.schemas

Execução:
EXEC poly_cat_HeapsWithNCIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_HeapsWithNCIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        COUNT(i.index_id) AS NonClusteredIndexCount
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id AND i.type = 2 -- Non-Clustered
    WHERE NOT EXISTS (
        SELECT 1 FROM sys.indexes ic 
        WHERE ic.object_id = t.object_id AND ic.type IN (1, 5) -- Clustered ou Clustered Columnstore
    )
    AND t.is_ms_shipped = 0
    GROUP BY s.name, t.name
    ORDER BY NonClusteredIndexCount DESC, s.name, t.name;
END;
GO

EXEC poly_cat_HeapsWithNCIndexes;
GO
