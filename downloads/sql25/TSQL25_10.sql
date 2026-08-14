/*
=============================================================
TSQL25_10 - Sistema de Permissões e Controle de Acesso (RBAC)
=============================================================
Role-Based Access Control completo implementado em T-SQL.
Suporta usuários, roles, permissões granulares, herança
de roles e verificação de acesso em tempo real.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

-- Tabelas do sistema RBAC
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RBAC_Roles')
BEGIN
    CREATE TABLE dbo.RBAC_Roles (
        RoleId      INT IDENTITY(1,1) PRIMARY KEY,
        Nome        NVARCHAR(128) NOT NULL UNIQUE,
        Descricao   NVARCHAR(500) NULL,
        ParentRole  INT NULL REFERENCES dbo.RBAC_Roles(RoleId),
        Ativo       BIT NOT NULL DEFAULT 1,
        CriadoEm    DATETIME2(3) NOT NULL DEFAULT SYSDATETIME()
    );

    CREATE TABLE dbo.RBAC_Permissoes (
        PermissaoId INT IDENTITY(1,1) PRIMARY KEY,
        Recurso     NVARCHAR(256) NOT NULL,  -- ex: 'clientes', 'relatorios.vendas'
        Acao        NVARCHAR(50)  NOT NULL,   -- ex: 'ler', 'criar', 'editar', 'deletar', 'admin'
        Descricao   NVARCHAR(500) NULL,

        CONSTRAINT UQ_Permissao UNIQUE (Recurso, Acao),
        INDEX IX_Permissao_Recurso (Recurso)
    );

    CREATE TABLE dbo.RBAC_RolePermissoes (
        RoleId      INT NOT NULL REFERENCES dbo.RBAC_Roles(RoleId),
        PermissaoId INT NOT NULL REFERENCES dbo.RBAC_Permissoes(PermissaoId),
        ConcedidoEm DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
        ConcedidoPor NVARCHAR(256) NOT NULL DEFAULT SUSER_SNAME(),

        PRIMARY KEY (RoleId, PermissaoId)
    );

    CREATE TABLE dbo.RBAC_UsuarioRoles (
        UsuarioId   NVARCHAR(256) NOT NULL,
        RoleId      INT NOT NULL REFERENCES dbo.RBAC_Roles(RoleId),
        AtribuidoEm DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
        AtribuidoPor NVARCHAR(256) NOT NULL DEFAULT SUSER_SNAME(),

        PRIMARY KEY (UsuarioId, RoleId),
        INDEX IX_UsuarioRole_Usuario (UsuarioId)
    );
END
GO

-- Criar role
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_CriarRole
    @Nome        NVARCHAR(128),
    @Descricao   NVARCHAR(500) = NULL,
    @ParentRole  NVARCHAR(128) = NULL,
    @RoleId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ParentId INT = NULL;

    IF @ParentRole IS NOT NULL
    BEGIN
        SELECT @ParentId = RoleId FROM dbo.RBAC_Roles WHERE Nome = @ParentRole;
        IF @ParentId IS NULL
        BEGIN
            RAISERROR('Role pai não encontrada: %s', 16, 1, @ParentRole);
            RETURN -1;
        END
    END

    INSERT INTO dbo.RBAC_Roles (Nome, Descricao, ParentRole)
    VALUES (@Nome, @Descricao, @ParentId);

    SET @RoleId = SCOPE_IDENTITY();
END
GO

-- Criar permissão
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_CriarPermissao
    @Recurso     NVARCHAR(256),
    @Acao        NVARCHAR(50),
    @Descricao   NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.RBAC_Permissoes WHERE Recurso = @Recurso AND Acao = @Acao)
    BEGIN
        INSERT INTO dbo.RBAC_Permissoes (Recurso, Acao, Descricao)
        VALUES (@Recurso, @Acao, @Descricao);
    END
END
GO

-- Atribuir permissão a role
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_AtribuirPermissao
    @RoleNome    NVARCHAR(128),
    @Recurso     NVARCHAR(256),
    @Acao        NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RoleId INT, @PermId INT;

    SELECT @RoleId = RoleId FROM dbo.RBAC_Roles WHERE Nome = @RoleNome;
    SELECT @PermId = PermissaoId FROM dbo.RBAC_Permissoes WHERE Recurso = @Recurso AND Acao = @Acao;

    IF @RoleId IS NULL
    BEGIN RAISERROR('Role não encontrada: %s', 16, 1, @RoleNome); RETURN; END
    IF @PermId IS NULL
    BEGIN RAISERROR('Permissão não encontrada: %s.%s', 16, 1, @Recurso, @Acao); RETURN; END

    IF NOT EXISTS (SELECT 1 FROM dbo.RBAC_RolePermissoes WHERE RoleId = @RoleId AND PermissaoId = @PermId)
    BEGIN
        INSERT INTO dbo.RBAC_RolePermissoes (RoleId, PermissaoId)
        VALUES (@RoleId, @PermId);
    END
END
GO

-- Atribuir role a usuário
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_AtribuirRole
    @UsuarioId   NVARCHAR(256),
    @RoleNome    NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RoleId INT;
    SELECT @RoleId = RoleId FROM dbo.RBAC_Roles WHERE Nome = @RoleNome AND Ativo = 1;

    IF @RoleId IS NULL
    BEGIN RAISERROR('Role não encontrada ou inativa: %s', 16, 1, @RoleNome); RETURN; END

    IF NOT EXISTS (SELECT 1 FROM dbo.RBAC_UsuarioRoles WHERE UsuarioId = @UsuarioId AND RoleId = @RoleId)
    BEGIN
        INSERT INTO dbo.RBAC_UsuarioRoles (UsuarioId, RoleId)
        VALUES (@UsuarioId, @RoleId);
    END
END
GO

-- Verificar se usuário tem permissão (com herança de roles)
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_TemPermissao
    @UsuarioId   NVARCHAR(256),
    @Recurso     NVARCHAR(256),
    @Acao        NVARCHAR(50),
    @Permitido   BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Permitido = 0;

    -- CTE recursiva para resolver herança de roles
    ;WITH RolesHierarquia AS (
        -- Roles diretas do usuário
        SELECT r.RoleId, r.ParentRole
        FROM dbo.RBAC_UsuarioRoles ur
        INNER JOIN dbo.RBAC_Roles r ON ur.RoleId = r.RoleId
        WHERE ur.UsuarioId = @UsuarioId AND r.Ativo = 1

        UNION ALL

        -- Roles pai (herança)
        SELECT rp.RoleId, rp.ParentRole
        FROM dbo.RBAC_Roles rp
        INNER JOIN RolesHierarquia rh ON rp.RoleId = rh.ParentRole
        WHERE rp.Ativo = 1
    )
    SELECT @Permitido = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM RolesHierarquia rh
    INNER JOIN dbo.RBAC_RolePermissoes rp ON rh.RoleId = rp.RoleId
    INNER JOIN dbo.RBAC_Permissoes p ON rp.PermissaoId = p.PermissaoId
    WHERE p.Recurso = @Recurso AND p.Acao = @Acao;
END
GO

-- Listar todas as permissões de um usuário
CREATE OR ALTER PROCEDURE dbo.sp_RBAC_PermissoesUsuario
    @UsuarioId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH RolesHierarquia AS (
        SELECT r.RoleId, r.Nome AS RoleNome, r.ParentRole, 0 AS Nivel
        FROM dbo.RBAC_UsuarioRoles ur
        INNER JOIN dbo.RBAC_Roles r ON ur.RoleId = r.RoleId
        WHERE ur.UsuarioId = @UsuarioId AND r.Ativo = 1

        UNION ALL

        SELECT rp.RoleId, rp.Nome, rp.ParentRole, rh.Nivel + 1
        FROM dbo.RBAC_Roles rp
        INNER JOIN RolesHierarquia rh ON rp.RoleId = rh.ParentRole
        WHERE rp.Ativo = 1
    )
    SELECT DISTINCT
        rh.RoleNome                  AS Role,
        p.Recurso,
        p.Acao,
        p.Descricao                  AS PermissaoDescricao,
        CASE WHEN rh.Nivel = 0 THEN 'Direta' ELSE 'Herdada' END AS Origem
    FROM RolesHierarquia rh
    INNER JOIN dbo.RBAC_RolePermissoes rp ON rh.RoleId = rp.RoleId
    INNER JOIN dbo.RBAC_Permissoes p ON rp.PermissaoId = p.PermissaoId
    ORDER BY p.Recurso, p.Acao;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- 1. Criar roles com herança
-- DECLARE @Id INT;
-- EXEC dbo.sp_RBAC_CriarRole 'viewer',  'Apenas leitura', NULL, @Id OUTPUT;
-- EXEC dbo.sp_RBAC_CriarRole 'editor',  'Pode editar',    'viewer', @Id OUTPUT;
-- EXEC dbo.sp_RBAC_CriarRole 'admin',   'Acesso total',   'editor', @Id OUTPUT;
--
-- -- 2. Criar permissões
-- EXEC dbo.sp_RBAC_CriarPermissao 'clientes', 'ler',     'Ler clientes';
-- EXEC dbo.sp_RBAC_CriarPermissao 'clientes', 'criar',   'Criar clientes';
-- EXEC dbo.sp_RBAC_CriarPermissao 'clientes', 'editar',  'Editar clientes';
-- EXEC dbo.sp_RBAC_CriarPermissao 'clientes', 'deletar', 'Deletar clientes';
--
-- -- 3. Atribuir permissões às roles
-- EXEC dbo.sp_RBAC_AtribuirPermissao 'viewer', 'clientes', 'ler';
-- EXEC dbo.sp_RBAC_AtribuirPermissao 'editor', 'clientes', 'criar';
-- EXEC dbo.sp_RBAC_AtribuirPermissao 'editor', 'clientes', 'editar';
-- EXEC dbo.sp_RBAC_AtribuirPermissao 'admin',  'clientes', 'deletar';
--
-- -- 4. Atribuir role ao usuário
-- EXEC dbo.sp_RBAC_AtribuirRole 'maria@empresa.com', 'editor';
--
-- -- 5. Verificar permissão (editor herda 'ler' do viewer)
-- DECLARE @Ok BIT;
-- EXEC dbo.sp_RBAC_TemPermissao 'maria@empresa.com', 'clientes', 'ler', @Ok OUTPUT;
-- PRINT CASE @Ok WHEN 1 THEN 'PERMITIDO' ELSE 'NEGADO' END;
-- >>> PERMITIDO
--
-- -- 6. Listar tudo
-- EXEC dbo.sp_RBAC_PermissoesUsuario 'maria@empresa.com';
