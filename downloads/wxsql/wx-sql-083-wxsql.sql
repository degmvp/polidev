/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat18.sql
Título..........: Catalog Explorer - Object Name Collisions
Procedure.......: poly_cat_ObjectNameCollisions
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Identificar objetos (tabelas, views, procedures) que possuem o mesmo nome, mas estão em schemas diferentes (poluição de namespace).

Aplicações:
- Organização de banco de dados
- Prevenção de erros de resolução de nomes em aplicações
- Revisão de padrões de nomenclatura

Catálogo utilizado:
sys.objects
sys.schemas

Execução:
EXEC poly_cat_ObjectNameCollisions;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ObjectNameCollisions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.name AS ObjectName,
        COUNT(DISTINCT o.schema_id) AS SchemaCount,
        STRING_AGG(CONCAT(s.name, ' [', o.type_desc, ']'), ', ') AS Locations
    FROM sys.objects o
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE o.is_ms_shipped = 0
      AND o.type IN ('U', 'V', 'P', 'FN', 'TF') -- Tabelas, Views, Procs, Functions
    GROUP BY o.name
    HAVING COUNT(DISTINCT o.schema_id) > 1
    ORDER BY SchemaCount DESC, ObjectName;
END;
GO

EXEC poly_cat_ObjectNameCollisions;
GO

