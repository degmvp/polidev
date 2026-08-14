/*
=============================================================
TSQL25_06 - Gerador de Relatórios Dinâmicos com Pivot
=============================================================
Cria relatórios pivotados dinamicamente a partir de qualquer
tabela. Transforma linhas em colunas automaticamente, ideal
para dashboards, análises e exportações.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

CREATE OR ALTER PROCEDURE dbo.sp_RelatorioPivotDinamico
    @Tabela              NVARCHAR(128),
    @ColunaLinha         NVARCHAR(128),     -- Campo que vira as linhas
    @ColunaPivot         NVARCHAR(128),     -- Campo que vira colunas
    @ColunaValor         NVARCHAR(128),     -- Campo com os valores
    @FuncaoAgregacao     NVARCHAR(10) = 'SUM',  -- SUM, COUNT, AVG, MAX, MIN
    @FiltroWhere         NVARCHAR(MAX) = NULL,
    @IncluirTotais       BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL            NVARCHAR(MAX);
    DECLARE @ColunasPivot   NVARCHAR(MAX);
    DECLARE @ColunasTotal   NVARCHAR(MAX);

    -- Obter valores distintos para as colunas do pivot
    SET @SQL = N'SELECT @cols = STRING_AGG(QUOTENAME(val), '', '')
                 WITHIN GROUP (ORDER BY val)
                 FROM (SELECT DISTINCT CAST(' + QUOTENAME(@ColunaPivot) +
                 ' AS NVARCHAR(256)) AS val FROM ' + QUOTENAME(@Tabela);

    IF @FiltroWhere IS NOT NULL
        SET @SQL = @SQL + ' WHERE ' + @FiltroWhere;

    SET @SQL = @SQL + ') AS DistinctVals';

    EXEC sp_executesql @SQL, N'@cols NVARCHAR(MAX) OUTPUT', @cols = @ColunasPivot OUTPUT;

    IF @ColunasPivot IS NULL
    BEGIN
        RAISERROR('Nenhum dado encontrado para pivotear.', 16, 1);
        RETURN -1;
    END

    -- Montar query do pivot
    SET @SQL = 'SELECT ' + QUOTENAME(@ColunaLinha) + ', ' + @ColunasPivot;

    -- Adicionar coluna de totais
    IF @IncluirTotais = 1
    BEGIN
        SET @ColunasTotal = REPLACE(@ColunasPivot, '],', '] +');
        SET @SQL = @SQL + ', (' + @ColunasTotal + ') AS [TOTAL]';
    END

    SET @SQL = @SQL +
        ' FROM (SELECT ' + QUOTENAME(@ColunaLinha) + ', ' +
        QUOTENAME(@ColunaPivot) + ', ' + QUOTENAME(@ColunaValor) +
        ' FROM ' + QUOTENAME(@Tabela);

    IF @FiltroWhere IS NOT NULL
        SET @SQL = @SQL + ' WHERE ' + @FiltroWhere;

    SET @SQL = @SQL + ') AS SourceData ' +
        'PIVOT (' + @FuncaoAgregacao + '(' + QUOTENAME(@ColunaValor) + ') ' +
        'FOR ' + QUOTENAME(@ColunaPivot) + ' IN (' + @ColunasPivot + ')) AS PivotTable ' +
        'ORDER BY ' + QUOTENAME(@ColunaLinha);

    EXEC sp_executesql @SQL;
END
GO

-- Relatório de resumo com agrupamento e percentuais
CREATE OR ALTER PROCEDURE dbo.sp_RelatorioResumo
    @Tabela          NVARCHAR(128),
    @ColunaAgrupar   NVARCHAR(128),
    @ColunaValor     NVARCHAR(128),
    @FiltroWhere     NVARCHAR(MAX) = NULL,
    @Top             INT           = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    ;WITH Resumo AS (
        SELECT
            ' + QUOTENAME(@ColunaAgrupar) + ' AS Grupo,
            COUNT(*)                         AS Quantidade,
            SUM(CAST(' + QUOTENAME(@ColunaValor) + ' AS DECIMAL(18,2)))  AS Total,
            AVG(CAST(' + QUOTENAME(@ColunaValor) + ' AS DECIMAL(18,2)))  AS Media,
            MIN(CAST(' + QUOTENAME(@ColunaValor) + ' AS DECIMAL(18,2)))  AS Minimo,
            MAX(CAST(' + QUOTENAME(@ColunaValor) + ' AS DECIMAL(18,2)))  AS Maximo
        FROM ' + QUOTENAME(@Tabela);

    IF @FiltroWhere IS NOT NULL
        SET @SQL = @SQL + ' WHERE ' + @FiltroWhere;

    SET @SQL = @SQL + '
        GROUP BY ' + QUOTENAME(@ColunaAgrupar) + '
    )
    SELECT TOP (' + CAST(@Top AS VARCHAR) + ')
        Grupo,
        Quantidade,
        Total,
        Media,
        Minimo,
        Maximo,
        CAST(ROUND(Quantidade * 100.0 / SUM(Quantidade) OVER(), 2) AS DECIMAL(5,2)) AS PercentualQtd,
        CAST(ROUND(Total * 100.0 / SUM(Total) OVER(), 2) AS DECIMAL(5,2)) AS PercentualValor
    FROM Resumo
    ORDER BY Total DESC';

    EXEC sp_executesql @SQL;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Relatório pivotado: Vendas por Vendedor x Mês
-- EXEC dbo.sp_RelatorioPivotDinamico
--     @Tabela          = 'Vendas',
--     @ColunaLinha     = 'Vendedor',
--     @ColunaPivot     = 'Mes',
--     @ColunaValor     = 'Valor',
--     @FuncaoAgregacao = 'SUM',
--     @IncluirTotais   = 1;
--
-- -- Resumo de vendas por categoria
-- EXEC dbo.sp_RelatorioResumo
--     @Tabela        = 'Vendas',
--     @ColunaAgrupar = 'Categoria',
--     @ColunaValor   = 'Valor',
--     @FiltroWhere   = 'Ano = 2025';
