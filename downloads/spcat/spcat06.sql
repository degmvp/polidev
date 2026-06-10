/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat06.sql
Título..........: Catalog Explorer - List Columns
Procedure.......: poly_cat_ListColumns
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as colunas de todas as tabelas existentes no banco atual.

Aplicações:
- Dicionário de dados
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.columns
sys.tables
sys.types

Execução:
EXEC poly_cat_ListColumns;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListColumns
AS
BEGIN
SET NOCOUNT ON;

SELECT
    t.name AS TableName,
    c.column_id AS ColumnPosition,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
     INNER JOIN sys.tables t
        ON c.object_id = t.object_id
     INNER JOIN sys.types ty
        ON c.user_type_id = ty.user_type_id
ORDER BY
    t.name,
    c.column_id;

END;
GO

EXEC poly_cat_ListColumns;
GO