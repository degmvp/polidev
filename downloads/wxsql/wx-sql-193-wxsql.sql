/*
=============================================================
TSQL25_03 - Gerenciador de Filas (Queue Manager)
=============================================================
Sistema de filas persistente para processamento assíncrono.
Suporta prioridades, retry automático, dead-letter queue,
e processamento concorrente seguro com locks.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

-- Tabela de filas
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FilaMensagens')
BEGIN
    CREATE TABLE dbo.FilaMensagens (
        MensagemId      BIGINT IDENTITY(1,1) PRIMARY KEY,
        Fila            NVARCHAR(128)    NOT NULL,
        Payload         NVARCHAR(MAX)    NOT NULL,
        Prioridade      INT              NOT NULL DEFAULT 0,
        Status          TINYINT          NOT NULL DEFAULT 0, -- 0=Pendente, 1=Processando, 2=Concluido, 3=Erro, 4=DeadLetter
        Tentativas      INT              NOT NULL DEFAULT 0,
        MaxTentativas   INT              NOT NULL DEFAULT 3,
        UltimoErro      NVARCHAR(MAX)    NULL,
        CriadoEm        DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        ProcessandoEm   DATETIME2(3)     NULL,
        ConcluidoEm     DATETIME2(3)     NULL,
        ProcessadoPor   NVARCHAR(256)    NULL,
        AgendarPara     DATETIME2(3)     NULL,  -- agendar para futuro
        CorrelationId   UNIQUEIDENTIFIER NULL,

        INDEX IX_Fila_Status_Prioridade (Fila, Status, Prioridade DESC, CriadoEm)
    );
END
GO

-- Enfileirar mensagem
CREATE OR ALTER PROCEDURE dbo.sp_EnfileirarMensagem
    @Fila            NVARCHAR(128),
    @Payload         NVARCHAR(MAX),
    @Prioridade      INT              = 0,
    @MaxTentativas   INT              = 3,
    @AgendarPara     DATETIME2        = NULL,
    @CorrelationId   UNIQUEIDENTIFIER = NULL,
    @MensagemId      BIGINT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.FilaMensagens (
        Fila, Payload, Prioridade, MaxTentativas,
        AgendarPara, CorrelationId
    )
    VALUES (
        @Fila, @Payload, @Prioridade, @MaxTentativas,
        @AgendarPara, @CorrelationId
    );

    SET @MensagemId = SCOPE_IDENTITY();
END
GO

-- Desenfileirar próxima mensagem (thread-safe com UPDLOCK)
CREATE OR ALTER PROCEDURE dbo.sp_DesenfileirarMensagem
    @Fila            NVARCHAR(128),
    @TimeoutSegundos INT = 300,
    @MensagemId      BIGINT        OUTPUT,
    @Payload         NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Agora DATETIME2(3) = SYSDATETIME();

    -- Recuperar mensagens travadas (timeout de processamento)
    UPDATE dbo.FilaMensagens
    SET Status = 0,
        ProcessandoEm = NULL,
        ProcessadoPor = NULL
    WHERE Fila = @Fila
      AND Status = 1
      AND DATEDIFF(SECOND, ProcessandoEm, @Agora) > @TimeoutSegundos;

    -- Pegar próxima mensagem com lock exclusivo
    ;WITH Proxima AS (
        SELECT TOP 1
            MensagemId, Payload
        FROM dbo.FilaMensagens WITH (UPDLOCK, READPAST)
        WHERE Fila = @Fila
          AND Status = 0
          AND (AgendarPara IS NULL OR AgendarPara <= @Agora)
        ORDER BY Prioridade DESC, CriadoEm ASC
    )
    UPDATE Proxima
    SET @MensagemId = Proxima.MensagemId,
        @Payload = Proxima.Payload
    FROM dbo.FilaMensagens fm
    INNER JOIN Proxima ON fm.MensagemId = Proxima.MensagemId;

    IF @MensagemId IS NOT NULL
    BEGIN
        UPDATE dbo.FilaMensagens
        SET Status = 1,
            ProcessandoEm = @Agora,
            ProcessadoPor = SUSER_SNAME(),
            Tentativas = Tentativas + 1
        WHERE MensagemId = @MensagemId;
    END
END
GO

-- Confirmar processamento com sucesso
CREATE OR ALTER PROCEDURE dbo.sp_ConfirmarMensagem
    @MensagemId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.FilaMensagens
    SET Status = 2,
        ConcluidoEm = SYSDATETIME()
    WHERE MensagemId = @MensagemId;
END
GO

-- Reportar falha (com retry automático ou dead-letter)
CREATE OR ALTER PROCEDURE dbo.sp_FalharMensagem
    @MensagemId BIGINT,
    @Erro       NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tentativas INT, @MaxTentativas INT;

    SELECT @Tentativas = Tentativas,
           @MaxTentativas = MaxTentativas
    FROM dbo.FilaMensagens
    WHERE MensagemId = @MensagemId;

    IF @Tentativas >= @MaxTentativas
    BEGIN
        -- Mover para dead-letter
        UPDATE dbo.FilaMensagens
        SET Status = 4,
            UltimoErro = @Erro,
            ConcluidoEm = SYSDATETIME()
        WHERE MensagemId = @MensagemId;
    END
    ELSE
    BEGIN
        -- Voltar para fila com delay exponencial
        UPDATE dbo.FilaMensagens
        SET Status = 0,
            UltimoErro = @Erro,
            ProcessandoEm = NULL,
            AgendarPara = DATEADD(SECOND, POWER(2, @Tentativas) * 5, SYSDATETIME())
        WHERE MensagemId = @MensagemId;
    END
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Enfileirar
-- DECLARE @Id BIGINT;
-- EXEC dbo.sp_EnfileirarMensagem
--     @Fila       = 'emails',
--     @Payload    = '{"para":"ana@ex.com","assunto":"Bem-vinda!"}',
--     @Prioridade = 10,
--     @MensagemId = @Id OUTPUT;
-- PRINT 'Enfileirada: ' + CAST(@Id AS VARCHAR);
--
-- -- Desenfileirar
-- DECLARE @MsgId BIGINT, @Dados NVARCHAR(MAX);
-- EXEC dbo.sp_DesenfileirarMensagem
--     @Fila       = 'emails',
--     @MensagemId = @MsgId OUTPUT,
--     @Payload    = @Dados OUTPUT;
-- PRINT @Dados;
--
-- -- Confirmar sucesso
-- EXEC dbo.sp_ConfirmarMensagem @MensagemId = @MsgId;
