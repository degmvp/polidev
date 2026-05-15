CREATE OR ALTER FUNCTION dbo.bb_fn04_formata_tamanho
(
    @bytes BIGINT
)
RETURNS VARCHAR(40)
AS
BEGIN
    DECLARE @retorno VARCHAR(40);

    SET @retorno =
        CASE
            WHEN @bytes >= 1073741824 THEN CAST(CAST(@bytes / 1073741824.0 AS DECIMAL(18,2)) AS VARCHAR(30)) + ' GB'
            WHEN @bytes >= 1048576 THEN CAST(CAST(@bytes / 1048576.0 AS DECIMAL(18,2)) AS VARCHAR(30)) + ' MB'
            WHEN @bytes >= 1024 THEN CAST(CAST(@bytes / 1024.0 AS DECIMAL(18,2)) AS VARCHAR(30)) + ' KB'
            ELSE CAST(@bytes AS VARCHAR(30)) + ' bytes'
        END;

    RETURN @retorno;
END;
GO