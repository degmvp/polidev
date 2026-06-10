/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat11.sql
Título..........: Catalog Explorer - Orphaned Users
Procedure.......: poly_cat_OrphanedUsers
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Identificar usuários do banco de dados que não possuem um login correspondente no servidor (órfãos).

Aplicações:
- Segurança e auditoria pós-migração
- Resolução de problemas de conexão (Error 18456)
- Limpeza de segurança

Catálogo utilizado:
sys.database_principals
sys.server_principals

Execução:
EXEC poly_cat_OrphanedUsers;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_OrphanedUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        dp.name AS UserName,
        dp.type_desc AS UserType,
        dp.create_date,
        dp.modify_date
    FROM sys.database_principals dp
    LEFT JOIN sys.server_principals sp 
        ON dp.sid = sp.sid
    WHERE dp.type IN ('S', 'U') -- SQL User, Windows User
      AND dp.name NOT IN ('guest', 'dbo', 'sys', 'INFORMATION_SCHEMA')
      AND sp.sid IS NULL;
END;
GO

EXEC poly_cat_OrphanedUsers;
GO
