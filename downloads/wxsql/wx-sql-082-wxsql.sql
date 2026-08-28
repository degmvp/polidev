/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat17.sql
Título..........: Catalog Explorer - Computed Columns Details
Procedure.......: poly_cat_ComputedColumns
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as colunas computadas do banco, exibindo a fórmula de cálculo e se a coluna é persistida (PERSISTED).

Aplicações:
- Documentação de regras de negócio no banco
- Análise de impacto para migrações
- Validação de uso de índices em colunas computadas

Catálogo utilized:
sys.computed_columns
sys.tables
sys.schemas

Execução:
EXEC poly_cat_ComputedColumns;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ComputedColumns
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        cc.name AS ColumnName,
        ty.name AS DataType,
        cc.is_persisted AS IsPersisted,
        cc.definition AS Formula
    FROM sys.computed_columns cc
    INNER JOIN sys.tables t ON cc.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.types ty ON cc.user_type_id = ty.user_type_id
    ORDER BY s.name, t.name, cc.name;
END;
GO

EXEC poly_cat_ComputedColumns;
GO


