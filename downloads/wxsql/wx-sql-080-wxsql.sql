/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat15.sql
Título..........: Catalog Explorer - Procedures With Recompile
Procedure.......: poly_cat_ProcsWithRecompile
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as Stored Procedures que possuem a diretiva WITH RECOMPILE, o que impede o reaproveitamento do plano de execução.

Aplicações:
- Análise de performance de rotinas críticas
- Revisão de código legado
- Identificação de procedimentos que causam alta carga na CPU

Catálogo utilizado:
sys.procedures
sys.sql_modules

Execução:
EXEC poly_cat_ProcsWithRecompile;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ProcsWithRecompile
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        p.name AS ProcedureName,
        p.create_date,
        p.modify_date
    FROM sys.procedures p
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
    WHERE OBJECTPROPERTYEX(p.object_id, 'ExecIsRecompiled') = 1
    ORDER BY s.name, p.name;
END;
GO

EXEC poly_cat_ProcsWithRecompile;
GO

