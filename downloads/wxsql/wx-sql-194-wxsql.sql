/*
=============================================================
TSQL25_04 - CRUD Dinâmico Universal com JSON
=============================================================
Procedures para INSERT, UPDATE, DELETE e SELECT genéricos
usando JSON como formato de entrada/saída. Perfeito para
APIs RESTful e microsserviços.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

-- INSERT dinâmico via JSON
CREATE OR ALTER PROCEDURE dbo.sp_InsertFromJson
    @Tabela      NVARCHAR(128),
    @JsonData    NVARCHAR(MAX),
    @NewId       BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Colunas NVARCHAR(MAX) = '';
    DECLARE @Valores NVARCHAR(MAX) = '';
    DECLARE @SQL     NVARCHAR(MAX);

    -- Extrair colunas e valores do JSON
    SELECT
        @Colunas = @Colunas + QUOTENAME([key]) + ', ',
        @Valores = @Valores + 'JSON_VALUE(@json, ''$.' + [key] + '''), '
    FROM OPENJSON(@JsonData);

    -- Remover vírgulas finais
    SET @Colunas = LEFT(@Colunas, LEN(@Colunas) - 1);
    SET @Valores = LEFT(@Valores, LEN(@Valores) - 1);

    SET @SQL = 'INSERT INTO ' + QUOTENAME(@Tabela) +
               ' (' + @Colunas + ') VALUES (' + @Valores + '); ' +
               'SET @id = SCOPE_IDENTITY();';

    EXEC sp_executesql @SQL,
        N'@json NVARCHAR(MAX), @id BIGINT OUTPUT',
        @json = @JsonData,
        @id = @NewId OUTPUT;
END
GO

-- UPDATE dinâmico via JSON
CREATE OR ALTER PROCEDURE dbo.sp_UpdateFromJson
    @Tabela          NVARCHAR(128),
    @ColunaChave     NVARCHAR(128),
    @ValorChave      NVARCHAR(500),
    @JsonData        NVARCHAR(MAX),
    @RowsAffected    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SetClause NVARCHAR(MAX) = '';
    DECLARE @SQL       NVARCHAR(MAX);

    -- Montar SET dinâmico
    SELECT @SetClause = @SetClause +
        QUOTENAME([key]) + ' = JSON_VALUE(@json, ''$.' + [key] + '''), '
    FROM OPENJSON(@JsonData)
    WHERE [key] <> @ColunaChave;  -- Não atualizar a PK

    IF LEN(@SetClause) < 2
    BEGIN
        RAISERROR('Nenhuma coluna para atualizar.', 16, 1);
        RETURN -1;
    END

    SET @SetClause = LEFT(@SetClause, LEN(@SetClause) - 1);

    SET @SQL = 'UPDATE ' + QUOTENAME(@Tabela) +
               ' SET ' + @SetClause +
               ' WHERE ' + QUOTENAME(@ColunaChave) + ' = @chave';

    EXEC sp_executesql @SQL,
        N'@json NVARCHAR(MAX), @chave NVARCHAR(500)',
        @json = @JsonData,
        @chave = @ValorChave;

    SET @RowsAffected = @@ROWCOUNT;
END
GO

-- SELECT com retorno JSON
CREATE OR ALTER PROCEDURE dbo.sp_SelectToJson
    @Tabela      NVARCHAR(128),
    @Where       NVARCHAR(MAX) = NULL,
    @OrderBy     NVARCHAR(256) = NULL,
    @Top         INT           = 100,
    @JsonResult  NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = 'SET @result = (SELECT TOP (@top) * FROM ' +
               QUOTENAME(@Tabela);

    IF @Where IS NOT NULL AND LEN(TRIM(@Where)) > 0
        SET @SQL = @SQL + ' WHERE ' + @Where;

    IF @OrderBy IS NOT NULL
        SET @SQL = @SQL + ' ORDER BY ' + @OrderBy;

    SET @SQL = @SQL + ' FOR JSON AUTO, INCLUDE_NULL_VALUES)';

    EXEC sp_executesql @SQL,
        N'@top INT, @result NVARCHAR(MAX) OUTPUT',
        @top = @Top,
        @result = @JsonResult OUTPUT;

    IF @JsonResult IS NULL
        SET @JsonResult = '[]';
END
GO

-- DELETE seguro com confirmação
CREATE OR ALTER PROCEDURE dbo.sp_DeleteSeguro
    @Tabela          NVARCHAR(128),
    @ColunaChave     NVARCHAR(128),
    @ValorChave      NVARCHAR(500),
    @DadosDeletados  NVARCHAR(MAX) OUTPUT,
    @RowsAffected    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    -- Capturar dados antes de deletar (para auditoria)
    SET @SQL = 'SET @dados = (SELECT * FROM ' + QUOTENAME(@Tabela) +
               ' WHERE ' + QUOTENAME(@ColunaChave) + ' = @chave FOR JSON AUTO)';

    EXEC sp_executesql @SQL,
        N'@chave NVARCHAR(500), @dados NVARCHAR(MAX) OUTPUT',
        @chave = @ValorChave,
        @dados = @DadosDeletados OUTPUT;

    -- Executar delete
    SET @SQL = 'DELETE FROM ' + QUOTENAME(@Tabela) +
               ' WHERE ' + QUOTENAME(@ColunaChave) + ' = @chave';

    EXEC sp_executesql @SQL,
        N'@chave NVARCHAR(500)',
        @chave = @ValorChave;

    SET @RowsAffected = @@ROWCOUNT;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- INSERT
-- DECLARE @Id BIGINT;
-- EXEC dbo.sp_InsertFromJson
--     @Tabela   = 'Clientes',
--     @JsonData = '{"Nome":"Ana Silva","Email":"ana@ex.com","Idade":28}',
--     @NewId    = @Id OUTPUT;
-- PRINT 'Novo ID: ' + CAST(@Id AS VARCHAR);
--
-- -- UPDATE
-- DECLARE @Rows INT;
-- EXEC dbo.sp_UpdateFromJson
--     @Tabela      = 'Clientes',
--     @ColunaChave = 'Id',
--     @ValorChave  = '1',
--     @JsonData    = '{"Email":"ana.nova@ex.com","Idade":29}',
--     @RowsAffected = @Rows OUTPUT;
--
-- -- SELECT como JSON
-- DECLARE @Json NVARCHAR(MAX);
-- EXEC dbo.sp_SelectToJson
--     @Tabela     = 'Clientes',
--     @Where      = 'Idade > 18',
--     @OrderBy    = 'Nome',
--     @JsonResult = @Json OUTPUT;
-- PRINT @Json;
