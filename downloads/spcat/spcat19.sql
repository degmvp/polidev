/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat19.sql
Título..........: Catalog Explorer - Encrypted Objects
Procedure.......: poly_cat_EncryptedObjects
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todos os objetos de banco de dados (Procedures, Functions, Triggers, Views) que possuem seu código-fonte criptografado (WITH ENCRYPTION).

Aplicações:
- Auditoria de segurança e propriedade intelectual
- Identificação de risco em lost-source-code scenarios
- Inventário de objetos que não podem ser rastreados via sys.sql_modules

Catálogo utilizado:
sys.objects
sys.sql_modules
sys.schemas

Execução:
EXEC poly_cat_EncryptedObjects;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_EncryptedObjects
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        o.name AS ObjectName,
        o.type_desc AS ObjectType,
        o.create_date,
        o.modify_date
    FROM sys.objects o
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    INNER JOIN sys.sql_modules m ON o.object_id = m.object_id
    WHERE m.is_encrypted = 1
    ORDER BY o.type_desc, s.name, o.name;
END;
GO

EXEC poly_cat_EncryptedObjects;
GO
