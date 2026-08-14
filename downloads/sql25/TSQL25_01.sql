/*
=============================================================
TSQL25_01 - Paginação Dinâmica com Ordenação e Filtro
=============================================================
Stored procedure genérica para paginação de qualquer tabela.
Suporta ordenação dinâmica, filtro por texto, contagem total
e metadados de paginação. Ideal para APIs REST e grids.

Compatível: SQL Server 2019+ / Azure SQL
=============================================================
*/

CREATE OR ALTER PROCEDURE dbo.sp_PaginacaoDinamica
    @Tabela          NVARCHAR(128),
    @Colunas         NVARCHAR(MAX)    = '*',
    @FiltroColuna    NVARCHAR(128)    = NULL,
    @FiltroValor     NVARCHAR(500)    = NULL,
    @OrdenarPor      NVARCHAR(128)    = NULL,
    @OrdemAsc        BIT              = 1,
    @Pagina          INT              = 1,
    @TamanhoPagina   INT              = 20,
    @TotalRegistros  INT              OUTPUT,
    @TotalPaginas    INT              OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- Validações de segurança
    IF @Tabela IS NULL OR LEN(TRIM(@Tabela)) = 0
    BEGIN
        RAISERROR('Nome da tabela é obrigatório.', 16, 1);
        RETURN -1;
    END

    -- Proteger contra SQL Injection no nome da tabela
    IF @Tabela LIKE '%[^a-zA-Z0-9_.[]%'
    BEGIN
        RAISERROR('Nome de tabela contém caracteres inválidos.', 16, 1);
        RETURN -1;
    END

    IF @Pagina < 1 SET @Pagina = 1;
    IF @TamanhoPagina < 1 SET @TamanhoPagina = 20;
    IF @TamanhoPagina > 1000 SET @TamanhoPagina = 1000;

    DECLARE @SQL        NVARCHAR(MAX);
    DECLARE @SQLCount   NVARCHAR(MAX);
    DECLARE @Where      NVARCHAR(MAX) = '';
    DECLARE @Order      NVARCHAR(256);
    DECLARE @Offset     INT = (@Pagina - 1) * @TamanhoPagina;

    -- Montar cláusula WHERE
    IF @FiltroColuna IS NOT NULL AND @FiltroValor IS NOT NULL
    BEGIN
        SET @Where = ' WHERE ' + QUOTENAME(@FiltroColuna) +
                     ' LIKE @pFiltro ';
    END

    -- Montar ORDER BY
    IF @OrdenarPor IS NOT NULL
        SET @Order = QUOTENAME(@OrdenarPor) +
                     CASE WHEN @OrdemAsc = 1 THEN ' ASC' ELSE ' DESC' END;
    ELSE
        SET @Order = '(SELECT NULL)';

    -- Contagem total
    SET @SQLCount = 'SELECT @cnt = COUNT(*) FROM ' + QUOTENAME(@Tabela) + @Where;

    EXEC sp_executesql @SQLCount,
        N'@pFiltro NVARCHAR(500), @cnt INT OUTPUT',
        @pFiltro = @FiltroValor,
        @cnt = @TotalRegistros OUTPUT;

    -- Calcular total de páginas
    SET @TotalPaginas = CEILING(CAST(@TotalRegistros AS FLOAT) / @TamanhoPagina);

    -- Consulta paginada
    SET @SQL = 'SELECT ' + @Colunas +
               ' FROM ' + QUOTENAME(@Tabela) +
               @Where +
               ' ORDER BY ' + @Order +
               ' OFFSET @pOffset ROWS FETCH NEXT @pFetch ROWS ONLY';

    EXEC sp_executesql @SQL,
        N'@pFiltro NVARCHAR(500), @pOffset INT, @pFetch INT',
        @pFiltro = @FiltroValor,
        @pOffset = @Offset,
        @pFetch = @TamanhoPagina;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- DECLARE @Total INT, @Paginas INT;
--
-- EXEC dbo.sp_PaginacaoDinamica
--     @Tabela         = 'dbo.Clientes',
--     @Colunas        = 'Id, Nome, Email, DataCadastro',
--     @FiltroColuna   = 'Nome',
--     @FiltroValor    = '%Silva%',
--     @OrdenarPor     = 'Nome',
--     @OrdemAsc       = 1,
--     @Pagina         = 1,
--     @TamanhoPagina  = 25,
--     @TotalRegistros = @Total OUTPUT,
--     @TotalPaginas   = @Paginas OUTPUT;
--
-- SELECT @Total AS TotalRegistros, @Paginas AS TotalPaginas;
