/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat05.sql
Título..........: Catalog Explorer - List Constraints
Procedure.......: poly_cat_ListConstraints
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as constraints existentes no banco atual.

Aplicações:
- Inventário de regras de integridade
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.objects

Execução:
EXEC poly_cat_ListConstraints;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListConstraints
AS
BEGIN
SET NOCOUNT ON;

SELECT
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT%'
ORDER BY
    TableName,
    ConstraintName;

END;
GO

EXEC poly_cat_ListConstraints;
GO