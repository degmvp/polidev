/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat13.sql
Título..........: Catalog Explorer - Inconsistent Column Data Types
Procedure.......: poly_cat_InconsistentColumnTypes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar colunas que compartilham o mesmo nome em tabelas diferentes, mas possuem tipos de dados diferentes.

Aplicações:
- Auditoria de padronização de banco de dados
- Detecção de problemas em integrações de dados (ETL/ELT)
- Refatoração de modelo

Catálogo utilizado:
sys.columns
sys.tables
sys.types
sys.schemas

Execução:
EXEC poly_cat_InconsistentColumnTypes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_InconsistentColumnTypes
AS
BEGIN
    SET NOCOUNT ON;

    WITH ColTypes AS (
        SELECT 
            c.name AS ColumnName,
            t.name AS TableName,
            s.name AS SchemaName,
            ty.name AS DataType,
            c.max_length,
            c.precision,
            c.scale,
            ROW_NUMBER() OVER(PARTITION BY c.name ORDER BY t.name) AS RowNum
        FROM sys.columns c
        INNER JOIN sys.tables t ON c.object_id = t.object_id
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE t.is_ms_shipped = 0
    )
    SELECT 
        ColumnName,
        COUNT(*) AS Occurrences,
        STRING_AGG(CONCAT(SchemaName, '.', TableName, ' (', DataType, ')'), ', ') AS Details
    FROM ColTypes
    GROUP BY ColumnName
    HAVING COUNT(DISTINCT DataType) > 1
    ORDER BY Occurrences DESC;
END;
GO

EXEC poly_cat_InconsistentColumnTypes;
GO
