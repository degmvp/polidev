/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat20.sql
Título..........: Catalog Explorer - Cross-Database Dependencies
Procedure.......: poly_cat_CrossDatabaseDependencies
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar objetos no banco atual que fazem referência a objetos em OUTROS bancos de dados (ex: SELECT * FROM OutroBanco.dbo.Tabela).

Aplicações:
- Mapeamento de acoplamento entre sistemas
- Planejamento de migração ou descontinuação de bancos
- Análise de impacto para mudanças de nome de bancos

Catálogo utilizado:
sys.sql_expression_dependencies
sys.objects
sys.schemas

Execução:
EXEC poly_cat_CrossDatabaseDependencies;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_CrossDatabaseDependencies
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        o.name AS ObjectName,
        o.type_desc AS ObjectType,
        sed.referenced_database_name AS TargetDatabase,
        ISNULL(sed.referenced_schema_name, 'dbo') AS TargetSchema,
        sed.referenced_entity_name AS TargetObject,
        sed.referenced_class_desc AS TargetType
    FROM sys.sql_expression_dependencies sed
    INNER JOIN sys.objects o ON sed.referencing_id = o.object_id
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE sed.referenced_database_name IS NOT NULL
      AND sed.referenced_class = 1 -- Apenas objetos (tabelas, views, procs)
    ORDER BY sed.referenced_database_name, s.name, o.name;
END;
GO

EXEC poly_cat_CrossDatabaseDependencies;
GO