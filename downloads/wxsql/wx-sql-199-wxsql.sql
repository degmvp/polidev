/*
=============================================================
TSQL25_09 - Gerenciador de Configurações (Key-Value Store)
=============================================================
Sistema de configurações tipado e versionado em banco.
Suporta tipos diversos, valores padrão, categorias,
histórico de alterações e importação/exportação JSON.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Configuracoes')
BEGIN
    CREATE TABLE dbo.Configuracoes (
        Chave           NVARCHAR(256)    NOT NULL PRIMARY KEY,
        Valor           NVARCHAR(MAX)    NOT NULL,
        ValorPadrao     NVARCHAR(MAX)    NULL,
        Tipo            VARCHAR(20)      NOT NULL DEFAULT 'string',  -- string, int, float, bool, json, datetime
        Categoria       NVARCHAR(128)    NOT NULL DEFAULT 'geral',
        Descricao       NVARCHAR(500)    NULL,
        CriadoEm        DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        AtualizadoEm    DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        AtualizadoPor   NVARCHAR(256)    NOT NULL DEFAULT SUSER_SNAME(),
        Versao          INT              NOT NULL DEFAULT 1,
        Ativo            BIT             NOT NULL DEFAULT 1,

        INDEX IX_Config_Categoria (Categoria)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ConfiguracoesHistorico')
BEGIN
    CREATE TABLE dbo.ConfiguracoesHistorico (
        HistoricoId     BIGINT IDENTITY(1,1) PRIMARY KEY,
        Chave           NVARCHAR(256)    NOT NULL,
        ValorAnterior   NVARCHAR(MAX)    NOT NULL,
        ValorNovo       NVARCHAR(MAX)    NOT NULL,
        Versao          INT              NOT NULL,
        AlteradoPor     NVARCHAR(256)    NOT NULL DEFAULT SUSER_SNAME(),
        AlteradoEm      DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),

        INDEX IX_ConfigHist_Chave (Chave, AlteradoEm DESC)
    );
END
GO

-- Obter configuração (com fallback para valor padrão)
CREATE OR ALTER PROCEDURE dbo.sp_ConfigGet
    @Chave   NVARCHAR(256),
    @Valor   NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Valor = CASE
        WHEN Ativo = 1 THEN Valor
        ELSE ISNULL(ValorPadrao, Valor)
    END
    FROM dbo.Configuracoes
    WHERE Chave = @Chave;

    IF @Valor IS NULL
        RAISERROR('Configuração não encontrada: %s', 16, 1, @Chave);
END
GO

-- Obter configuração tipada
CREATE OR ALTER FUNCTION dbo.fn_ConfigString(@Chave NVARCHAR(256))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Val NVARCHAR(MAX);
    SELECT @Val = Valor FROM dbo.Configuracoes WHERE Chave = @Chave AND Ativo = 1;
    RETURN @Val;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_ConfigInt(@Chave NVARCHAR(256))
RETURNS INT
AS
BEGIN
    DECLARE @Val INT;
    SELECT @Val = TRY_CAST(Valor AS INT) FROM dbo.Configuracoes WHERE Chave = @Chave AND Ativo = 1;
    RETURN @Val;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_ConfigBool(@Chave NVARCHAR(256))
RETURNS BIT
AS
BEGIN
    DECLARE @Val BIT;
    SELECT @Val = CASE LOWER(Valor)
        WHEN 'true' THEN 1 WHEN '1' THEN 1 WHEN 'yes' THEN 1 WHEN 'sim' THEN 1
        ELSE 0
    END
    FROM dbo.Configuracoes WHERE Chave = @Chave AND Ativo = 1;
    RETURN ISNULL(@Val, 0);
END
GO

-- Definir configuração (INSERT ou UPDATE com versionamento)
CREATE OR ALTER PROCEDURE dbo.sp_ConfigSet
    @Chave       NVARCHAR(256),
    @Valor       NVARCHAR(MAX),
    @Tipo        VARCHAR(20)      = 'string',
    @Categoria   NVARCHAR(128)    = 'geral',
    @Descricao   NVARCHAR(500)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ValorAnterior NVARCHAR(MAX);
    DECLARE @VersaoAtual INT;

    SELECT @ValorAnterior = Valor, @VersaoAtual = Versao
    FROM dbo.Configuracoes
    WHERE Chave = @Chave;

    IF @ValorAnterior IS NOT NULL
    BEGIN
        -- Registrar no histórico
        INSERT INTO dbo.ConfiguracoesHistorico (Chave, ValorAnterior, ValorNovo, Versao)
        VALUES (@Chave, @ValorAnterior, @Valor, @VersaoAtual + 1);

        -- Atualizar
        UPDATE dbo.Configuracoes
        SET Valor         = @Valor,
            Tipo          = @Tipo,
            Categoria     = @Categoria,
            Descricao     = ISNULL(@Descricao, Descricao),
            AtualizadoEm  = SYSDATETIME(),
            AtualizadoPor = SUSER_SNAME(),
            Versao        = @VersaoAtual + 1;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Configuracoes (Chave, Valor, ValorPadrao, Tipo, Categoria, Descricao)
        VALUES (@Chave, @Valor, @Valor, @Tipo, @Categoria, @Descricao);
    END
END
GO

-- Listar configurações por categoria
CREATE OR ALTER PROCEDURE dbo.sp_ConfigListar
    @Categoria NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Chave, Valor, Tipo, Categoria, Descricao,
        Versao, AtualizadoEm, AtualizadoPor, Ativo
    FROM dbo.Configuracoes
    WHERE (@Categoria IS NULL OR Categoria = @Categoria)
    ORDER BY Categoria, Chave;
END
GO

-- Exportar todas as configs como JSON
CREATE OR ALTER PROCEDURE dbo.sp_ConfigExportarJson
    @JsonResult NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @JsonResult = (
        SELECT Chave, Valor, Tipo, Categoria, Descricao
        FROM dbo.Configuracoes
        WHERE Ativo = 1
        FOR JSON AUTO
    );
END
GO

-- Importar configs de JSON
CREATE OR ALTER PROCEDURE dbo.sp_ConfigImportarJson
    @JsonData NVARCHAR(MAX),
    @Importados INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Importados = 0;

    DECLARE @Chave NVARCHAR(256), @Valor NVARCHAR(MAX);
    DECLARE @Tipo VARCHAR(20), @Categoria NVARCHAR(128), @Descricao NVARCHAR(500);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Chave, Valor, Tipo, Categoria, Descricao
        FROM OPENJSON(@JsonData)
        WITH (
            Chave     NVARCHAR(256) '$.Chave',
            Valor     NVARCHAR(MAX) '$.Valor',
            Tipo      VARCHAR(20)   '$.Tipo',
            Categoria NVARCHAR(128) '$.Categoria',
            Descricao NVARCHAR(500) '$.Descricao'
        );

    OPEN cur;
    FETCH NEXT FROM cur INTO @Chave, @Valor, @Tipo, @Categoria, @Descricao;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_ConfigSet @Chave, @Valor, @Tipo, @Categoria, @Descricao;
        SET @Importados = @Importados + 1;
        FETCH NEXT FROM cur INTO @Chave, @Valor, @Tipo, @Categoria, @Descricao;
    END

    CLOSE cur;
    DEALLOCATE cur;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Definir configs
-- EXEC dbo.sp_ConfigSet 'app.nome',       'MeuApp',       'string', 'app';
-- EXEC dbo.sp_ConfigSet 'app.max_upload',  '10485760',     'int',    'app', 'Tamanho máximo de upload em bytes';
-- EXEC dbo.sp_ConfigSet 'email.smtp_host', 'smtp.ex.com',  'string', 'email';
-- EXEC dbo.sp_ConfigSet 'feature.dark_mode', 'true',       'bool',   'features';
--
-- -- Ler configs
-- SELECT dbo.fn_ConfigString('app.nome');        -- >>> 'MeuApp'
-- SELECT dbo.fn_ConfigInt('app.max_upload');      -- >>> 10485760
-- SELECT dbo.fn_ConfigBool('feature.dark_mode');  -- >>> 1
--
-- -- Listar por categoria
-- EXEC dbo.sp_ConfigListar @Categoria = 'app';
