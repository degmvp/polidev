/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat26.sql
Título..........: Index Series - Filtered Indexes Analysis
Procedure.......: poly_cat_FilteredIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Mapear todos os índices filtrados do banco, exibindo a cláusula WHERE aplicada a eles.
Índices filtrados são ótimos para performance quando bem usados.

Aplicações:
- Documentação de estratégias de otimização avançada
- Auditoria de queries que lidam com subconjuntos de dados (ex: WHERE IS NOT NULL)
- Mapeamento de arquitetura fina

Catálogo utilizado:
sys.indexes
sys.tables
sys.schemas

Execução:
EXEC poly_cat_FilteredIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_FilteredIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        i.filter_definition AS FilterClause
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i.has_filter = 1
    ORDER BY s.name, t.name, i.name;
END;
GO

EXEC poly_cat_FilteredIndexes;
GO
