/*
=============================================================
TSQL25_05 - Controle de Concorrência com Locks Distribuídos
=============================================================
Sistema de locks aplicativos para controlar acesso concorrente
a recursos compartilhados. Usa sp_getapplock do SQL Server
com wrapper amigável, timeout e auto-release.

Compatível: SQL Server 2012+ / Azure SQL
=============================================================
*/

-- Tabela de registro de locks (para monitoramento)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LockRegistry')
BEGIN
    CREATE TABLE dbo.LockRegistry (
        LockId          BIGINT IDENTITY(1,1) PRIMARY KEY,
        Recurso         NVARCHAR(256)    NOT NULL,
        Proprietario    NVARCHAR(256)    NOT NULL DEFAULT SUSER_SNAME(),
        AdquiridoEm     DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        LiberadoEm      DATETIME2(3)     NULL,
        TimeoutMs       INT              NOT NULL,
        Status          VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',

        INDEX IX_Lock_Recurso (Recurso, Status)
    );
END
GO

-- Adquirir lock exclusivo em um recurso
CREATE OR ALTER PROCEDURE dbo.sp_AdquirirLock
    @Recurso         NVARCHAR(256),
    @TimeoutMs       INT = 5000,
    @LockId          BIGINT OUTPUT,
    @Sucesso         BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result INT;

    -- Tentar adquirir lock via sp_getapplock
    EXEC @Result = sp_getapplock
        @Resource    = @Recurso,
        @LockMode    = 'Exclusive',
        @LockOwner   = 'Session',
        @LockTimeout = @TimeoutMs;

    IF @Result >= 0  -- 0 = granted, 1 = granted after wait
    BEGIN
        SET @Sucesso = 1;

        INSERT INTO dbo.LockRegistry (Recurso, TimeoutMs)
        VALUES (@Recurso, @TimeoutMs);

        SET @LockId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Sucesso = 0;
        SET @LockId = NULL;

        -- Log de falha
        INSERT INTO dbo.LockRegistry (Recurso, TimeoutMs, Status)
        VALUES (@Recurso, @TimeoutMs, 'DENIED');
    END
END
GO

-- Liberar lock
CREATE OR ALTER PROCEDURE dbo.sp_LiberarLock
    @Recurso    NVARCHAR(256),
    @LockId     BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC sp_releaseapplock
        @Resource  = @Recurso,
        @LockOwner = 'Session';

    IF @LockId IS NOT NULL
    BEGIN
        UPDATE dbo.LockRegistry
        SET LiberadoEm = SYSDATETIME(),
            Status = 'RELEASED'
        WHERE LockId = @LockId;
    END
END
GO

-- Executar operação com lock automático (acquire + execute + release)
CREATE OR ALTER PROCEDURE dbo.sp_ExecutarComLock
    @Recurso         NVARCHAR(256),
    @SQL             NVARCHAR(MAX),
    @TimeoutMs       INT = 5000,
    @Sucesso         BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LockResult INT;

    BEGIN TRY
        -- Adquirir lock
        EXEC @LockResult = sp_getapplock
            @Resource    = @Recurso,
            @LockMode    = 'Exclusive',
            @LockOwner   = 'Transaction',
            @LockTimeout = @TimeoutMs;

        IF @LockResult < 0
        BEGIN
            SET @Sucesso = 0;
            RAISERROR('Não foi possível adquirir lock no recurso: %s', 16, 1, @Recurso);
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Executar a operação protegida
        EXEC sp_executesql @SQL;

        COMMIT TRANSACTION;
        SET @Sucesso = 1;

        EXEC sp_releaseapplock @Resource = @Recurso, @LockOwner = 'Transaction';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Sucesso = 0;

        EXEC sp_releaseapplock @Resource = @Recurso, @LockOwner = 'Transaction';

        THROW;
    END CATCH
END
GO

-- Verificar locks ativos
CREATE OR ALTER PROCEDURE dbo.sp_VerificarLocks
    @Recurso NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LockId,
        Recurso,
        Proprietario,
        AdquiridoEm,
        DATEDIFF(SECOND, AdquiridoEm, SYSDATETIME()) AS SegundosAtivo,
        Status
    FROM dbo.LockRegistry WITH (NOLOCK)
    WHERE Status = 'ACTIVE'
      AND (@Recurso IS NULL OR Recurso = @Recurso)
    ORDER BY AdquiridoEm DESC;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Lock manual
-- DECLARE @LkId BIGINT, @Ok BIT;
-- EXEC dbo.sp_AdquirirLock
--     @Recurso   = 'processo:faturamento',
--     @TimeoutMs = 10000,
--     @LockId    = @LkId OUTPUT,
--     @Sucesso   = @Ok OUTPUT;
--
-- IF @Ok = 1
-- BEGIN
--     PRINT 'Lock adquirido! Executando processo...';
--     -- ... operação crítica ...
--     EXEC dbo.sp_LiberarLock @Recurso = 'processo:faturamento', @LockId = @LkId;
-- END
--
-- -- Lock automático
-- DECLARE @Resultado BIT;
-- EXEC dbo.sp_ExecutarComLock
--     @Recurso   = 'saldo:conta:42',
--     @SQL       = N'UPDATE Contas SET Saldo = Saldo - 100 WHERE ContaId = 42',
--     @TimeoutMs = 5000,
--     @Sucesso   = @Resultado OUTPUT;
