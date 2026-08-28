/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat01.sql
Título..........: Catalog Explorer - List Tables
Procedure.......: poly_cat_ListTables
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as tabelas existentes no banco atual.

Aplicações:
- Inventário de tabelas
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.tables
sys.schemas

Execução:
EXEC poly_cat_ListTables;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListTables
AS
BEGIN
SET NOCOUNT ON;

```
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    t.create_date,
    t.type_desc
FROM sys.tables t
     INNER JOIN sys.schemas s
        ON t.schema_id = s.schema_id
ORDER BY
    s.name,
    t.name;
```

END;
GO

EXEC poly_cat_ListTables;
GO
