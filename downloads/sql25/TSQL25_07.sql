/*
=============================================================
TSQL25_07 - Sistema de Cache em Tabela com Expiração
=============================================================
Cache de resultados de queries pesadas armazenado em tabela.
Suporta TTL, invalidação por chave ou padrão, e limpeza
automática de entradas expiradas.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CacheStore')
BEGIN
    CREATE TABLE dbo.CacheStore (
        CacheKey        NVARCHAR(500)    NOT NULL PRIMARY KEY,
        CacheValue      NVARCHAR(MAX)    NOT NULL,
        Categoria       NVARCHAR(128)    NULL,
        CriadoEm        DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        ExpiraEm        DATETIME2(3)     NOT NULL,
        UltimoAcesso    DATETIME2(3)     NOT NULL DEFAULT SYSDATETIME(),
        HitCount        BIGINT           NOT NULL DEFAULT 0,
        TamanhoBytes    AS (DATALENGTH(CacheValue)) PERSISTED,

        INDEX IX_Cache_Expira (ExpiraEm),
        INDEX IX_Cache_Categoria (Categoria)
    );
END
GO

-- Inserir ou atualizar cache
CREATE OR ALTER PROCEDURE dbo.sp_CacheSet
    @Chave       NVARCHAR(500),
    @Valor       NVARCHAR(MAX),
    @TtlSegundos INT = 300,
    @Categoria   NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Expira DATETIME2(3) = DATEADD(SECOND, @TtlSegundos, SYSDATETIME());

    MERGE INTO dbo.CacheStore AS target
    USING (SELECT @Chave AS CacheKey) AS source
    ON target.CacheKey = source.CacheKey
    WHEN MATCHED THEN
        UPDATE SET
            CacheValue   = @Valor,
            Categoria    = ISNULL(@Categoria, target.Categoria),
            ExpiraEm     = @Expira,
            UltimoAcesso = SYSDATETIME(),
            HitCount     = 0
    WHEN NOT MATCHED THEN
        INSERT (CacheKey, CacheValue, Categoria, ExpiraEm)
        VALUES (@Chave, @Valor, @Categoria, @Expira);
END
GO

-- Buscar do cache
CREATE OR ALTER PROCEDURE dbo.sp_CacheGet
    @Chave   NVARCHAR(500),
    @Valor   NVARCHAR(MAX) OUTPUT,
    @Found   BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Found = 0;
    SET @Valor = NULL;

    UPDATE dbo.CacheStore
    SET @Valor = CacheValue,
        UltimoAcesso = SYSDATETIME(),
        HitCount = HitCount + 1,
        @Found = 1
    WHERE CacheKey = @Chave
      AND ExpiraEm > SYSDATETIME();

    -- Se expirado, remover
    IF @Found = 0
    BEGIN
        DELETE FROM dbo.CacheStore
        WHERE CacheKey = @Chave
          AND ExpiraEm <= SYSDATETIME();
    END
END
GO

-- Invalidar cache por chave ou padrão
CREATE OR ALTER PROCEDURE dbo.sp_CacheInvalidar
    @Chave       NVARCHAR(500)  = NULL,
    @Categoria   NVARCHAR(128)  = NULL,
    @Padrao      NVARCHAR(500)  = NULL,  -- LIKE pattern
    @Removidos   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Chave IS NOT NULL
    BEGIN
        DELETE FROM dbo.CacheStore WHERE CacheKey = @Chave;
        SET @Removidos = @@ROWCOUNT;
    END
    ELSE IF @Categoria IS NOT NULL
    BEGIN
        DELETE FROM dbo.CacheStore WHERE Categoria = @Categoria;
        SET @Removidos = @@ROWCOUNT;
    END
    ELSE IF @Padrao IS NOT NULL
    BEGIN
        DELETE FROM dbo.CacheStore WHERE CacheKey LIKE @Padrao;
        SET @Removidos = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        -- Limpar tudo
        DELETE FROM dbo.CacheStore;
        SET @Removidos = @@ROWCOUNT;
    END
END
GO

-- Limpeza automática de expirados
CREATE OR ALTER PROCEDURE dbo.sp_CacheLimpar
    @BatchSize   INT = 1000,
    @Removidos   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE TOP (@BatchSize) FROM dbo.CacheStore
    WHERE ExpiraEm <= SYSDATETIME();

    SET @Removidos = @@ROWCOUNT;
END
GO

-- Estatísticas do cache
CREATE OR ALTER PROCEDURE dbo.sp_CacheStats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(*)                                             AS TotalEntradas,
        SUM(CASE WHEN ExpiraEm > SYSDATETIME() THEN 1 ELSE 0 END) AS Ativas,
        SUM(CASE WHEN ExpiraEm <= SYSDATETIME() THEN 1 ELSE 0 END) AS Expiradas,
        SUM(HitCount)                                        AS TotalHits,
        CAST(SUM(TamanhoBytes) / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS TamanhoMB,
        MIN(CriadoEm)                                        AS EntradaMaisAntiga,
        MAX(CriadoEm)                                        AS EntradaMaisNova
    FROM dbo.CacheStore;

    -- Top 10 mais acessadas
    SELECT TOP 10
        CacheKey, Categoria, HitCount, UltimoAcesso,
        CAST(TamanhoBytes / 1024.0 AS DECIMAL(10,2)) AS TamanhoKB
    FROM dbo.CacheStore
    WHERE ExpiraEm > SYSDATETIME()
    ORDER BY HitCount DESC;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Armazenar resultado pesado no cache (TTL 10 min)
-- EXEC dbo.sp_CacheSet
--     @Chave       = 'relatorio:vendas:2025-01',
--     @Valor       = '{"total":150000,"itens":342}',
--     @TtlSegundos = 600,
--     @Categoria   = 'relatorios';
--
-- -- Buscar do cache
-- DECLARE @Val NVARCHAR(MAX), @Hit BIT;
-- EXEC dbo.sp_CacheGet
--     @Chave = 'relatorio:vendas:2025-01',
--     @Valor = @Val OUTPUT,
--     @Found = @Hit OUTPUT;
--
-- IF @Hit = 1
--     PRINT 'Cache hit: ' + @Val;
-- ELSE
--     PRINT 'Cache miss - executar query pesada';
--
-- -- Estatísticas
-- EXEC dbo.sp_CacheStats;
