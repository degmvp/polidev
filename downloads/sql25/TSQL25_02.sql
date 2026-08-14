/*
=============================================================
TSQL25_02 - Auditoria Automática de Alterações (Change Log)
=============================================================
Sistema completo de auditoria que registra INSERT, UPDATE e
DELETE em qualquer tabela. Armazena valores antigos e novos
em JSON, com metadados de quem/quando/onde alterou.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

-- Tabela de auditoria centralizada
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLog')
BEGIN
    CREATE TABLE dbo.AuditLog (
        AuditId         BIGINT IDENTITY(1,1) PRIMARY KEY,
        Tabela          NVARCHAR(256)   NOT NULL,
        Operacao        CHAR(1)         NOT NULL,  -- I=Insert, U=Update, D=Delete
        ChavePrimaria   NVARCHAR(500)   NOT NULL,
        DadosAntigos    NVARCHAR(MAX)   NULL,      -- JSON
        DadosNovos      NVARCHAR(MAX)   NULL,      -- JSON
        ColunasMudadas  NVARCHAR(MAX)   NULL,      -- JSON array
        Usuario         NVARCHAR(256)   NOT NULL DEFAULT SUSER_SNAME(),
        HostName        NVARCHAR(256)   NOT NULL DEFAULT HOST_NAME(),
        AppName         NVARCHAR(256)   NULL,
        DataHora        DATETIME2(3)    NOT NULL DEFAULT SYSDATETIME(),
        TransacaoId     BIGINT          NULL,

        INDEX IX_AuditLog_Tabela_Data (Tabela, DataHora DESC),
        INDEX IX_AuditLog_Usuario (Usuario, DataHora DESC)
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarAuditoria
    @Tabela          NVARCHAR(256),
    @Operacao        CHAR(1),           -- 'I', 'U', 'D'
    @ChavePrimaria   NVARCHAR(500),
    @DadosAntigos    NVARCHAR(MAX) = NULL,
    @DadosNovos      NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ColunasMudadas NVARCHAR(MAX) = NULL;

    -- Detectar colunas que mudaram (apenas para UPDATE)
    IF @Operacao = 'U' AND @DadosAntigos IS NOT NULL AND @DadosNovos IS NOT NULL
    BEGIN
        SELECT @ColunasMudadas = (
            SELECT STRING_AGG(QUOTENAME(a.[key]), ', ')
            FROM OPENJSON(@DadosAntigos) a
            INNER JOIN OPENJSON(@DadosNovos) n ON a.[key] = n.[key]
            WHERE a.[value] <> n.[value]
               OR (a.[value] IS NULL AND n.[value] IS NOT NULL)
               OR (a.[value] IS NOT NULL AND n.[value] IS NULL)
        );
    END

    INSERT INTO dbo.AuditLog (
        Tabela, Operacao, ChavePrimaria,
        DadosAntigos, DadosNovos, ColunasMudadas,
        AppName, TransacaoId
    )
    VALUES (
        @Tabela, @Operacao, @ChavePrimaria,
        @DadosAntigos, @DadosNovos, @ColunasMudadas,
        APP_NAME(), CURRENT_TRANSACTION_ID()
    );
END
GO

-- Procedure para consultar histórico de uma entidade
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarAuditoria
    @Tabela          NVARCHAR(256)    = NULL,
    @ChavePrimaria   NVARCHAR(500)    = NULL,
    @Usuario         NVARCHAR(256)    = NULL,
    @DataInicio      DATETIME2        = NULL,
    @DataFim         DATETIME2        = NULL,
    @Top             INT              = 100
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        AuditId,
        Tabela,
        CASE Operacao
            WHEN 'I' THEN 'INSERT'
            WHEN 'U' THEN 'UPDATE'
            WHEN 'D' THEN 'DELETE'
        END AS Operacao,
        ChavePrimaria,
        DadosAntigos,
        DadosNovos,
        ColunasMudadas,
        Usuario,
        HostName,
        DataHora
    FROM dbo.AuditLog WITH (NOLOCK)
    WHERE (@Tabela IS NULL OR Tabela = @Tabela)
      AND (@ChavePrimaria IS NULL OR ChavePrimaria = @ChavePrimaria)
      AND (@Usuario IS NULL OR Usuario = @Usuario)
      AND (@DataInicio IS NULL OR DataHora >= @DataInicio)
      AND (@DataFim IS NULL OR DataHora <= @DataFim)
    ORDER BY DataHora DESC;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Registrar uma alteração
-- EXEC dbo.sp_RegistrarAuditoria
--     @Tabela        = 'dbo.Clientes',
--     @Operacao      = 'U',
--     @ChavePrimaria = '42',
--     @DadosAntigos  = '{"Nome":"Maria","Email":"maria@old.com"}',
--     @DadosNovos    = '{"Nome":"Maria","Email":"maria@new.com"}';
--
-- -- Consultar histórico
-- EXEC dbo.sp_ConsultarAuditoria
--     @Tabela       = 'dbo.Clientes',
--     @DataInicio   = '2025-01-01';
