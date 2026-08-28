/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat12.sql
Título..........: Catalog Explorer - Tables Without Primary Key
Procedure.......: poly_cat_TablesWithoutPK
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar tabelas de usuário que não possuem uma Chave Primária definida.

Aplicações:
- Auditoria de modelagem de dados
- Identificação de tabelas potencialmente problemáticas para replicação/ORM
- Engenharia reversa de qualidade

Catálogo utilizado:
sys.tables
sys.indexes
sys.schemas

Execução:
EXEC poly_cat_TablesWithoutPK;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_TablesWithoutPK
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        t.create_date
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0
      AND NOT EXISTS (
          SELECT 1 
          FROM sys.indexes i 
          WHERE i.object_id = t.object_id 
            AND i.is_primary_key = 1
      )
    ORDER BY s.name, t.name;
END;
GO

EXEC poly_cat_TablesWithoutPK;
GO

