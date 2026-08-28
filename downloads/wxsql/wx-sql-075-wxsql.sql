/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat10.sql
Título..........: Catalog Explorer - List Permissions
Procedure.......: poly_cat_ListPermissions
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as permissões concedidas a usuários e roles do banco atual.

Aplicações:
- Auditoria de segurança
- Governança de acessos
- Engenharia reversa
- Documentação automática

Catálogo utilizado:
sys.database_permissions
sys.database_principals
sys.objects

Execução:
EXEC poly_cat_ListPermissions;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListPermissions
AS
BEGIN
SET NOCOUNT ON;

SELECT
    pr.name AS PrincipalName,
    pr.type_desc AS PrincipalType,
    pe.permission_name AS PermissionName,
    pe.state_desc AS PermissionState,
    o.name AS ObjectName
FROM sys.database_permissions pe
     INNER JOIN sys.database_principals pr
        ON pe.grantee_principal_id = pr.principal_id
     LEFT JOIN sys.objects o
        ON pe.major_id = o.object_id
ORDER BY
    pr.name,
    pe.permission_name;

END;
GO

EXEC poly_cat_ListPermissions;
GO