/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat29.sql
Título..........: Index Series - IGNORE_DUP_KEY Usage
Procedure.......: poly_cat_IgnoreDupKeyIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar índices criados com a propriedade IGNORE_DUP_KEY = ON. 
Esta opção mascara erros de inserção de dados duplicados silenciosamente (inserta um e ignora o outro),
o que geralmente esconde bugs na aplicação.

Aplicações:
- Auditoria de integridade de dados
- Revisão de padrões de desenvolvimento (muitas vezes usado como "gambiarra")
- Depuração de dados "desaparecidos"

Catálogo utilizado:
sys.indexes
sys.tables
sys.schemas

Execução:
EXEC poly_cat_IgnoreDupKeyIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_IgnoreDupKeyIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        i.type_desc AS IndexType
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i.ignore_dup_key = 1
    ORDER BY s.name, t.name, i.name;
END;
GO

EXEC poly_cat_IgnoreDupKeyIndexes;
GO