CREATE OR ALTER PROCEDURE dbo.bb_sp14_pesquisa_texto_banco_inteiro
    @texto NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        'SELECT ''' +
        s.name + '.' + t.name + ''' AS tabela, ''' +
        c.name + ''' AS coluna, COUNT(*) AS ocorrencias FROM [' +
        s.name + '].[' + t.name + '] WHERE TRY_CONVERT(NVARCHAR(MAX), [' +
        c.name + ']) LIKE ''%' + @texto + '%'';' AS comando_pesquisa
    FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.columns c ON c.object_id = t.object_id
    INNER JOIN sys.types ty ON ty.user_type_id = c.user_type_id
    WHERE ty.name IN ('varchar','nvarchar','char','nchar','text','ntext')
    ORDER BY s.name, t.name, c.column_id;
END;
GO