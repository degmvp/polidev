/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat09.sql
Título..........: Catalog Explorer - List Schemas
Procedure.......: poly_cat_ListSchemas
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todos os schemas definidos no banco atual.

Aplicações:
- Inventário de schemas
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.schemas

Execução:
EXEC poly_cat_ListSchemas;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListSchemas
AS
BEGIN
SET NOCOUNT ON;

SELECT
    schema_id AS SchemaID,
    name AS SchemaName,
    principal_id AS PrincipalID
FROM sys.schemas
ORDER BY
    name;

END;
GO

EXEC poly_cat_ListSchemas;
GO