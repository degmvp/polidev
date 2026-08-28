bbintel03.sql
DECLARE @schema SYSNAME = 'dbo';
DECLARE @table  SYSNAME = 'SUA_TABELA_AQUI';

DECLARE @full_name NVARCHAR(300) =
    QUOTENAME(@schema) + '.' + QUOTENAME(@table);

SELECT
    '-- SELECT' AS bloco,
    'SELECT ' +
    STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id) +
    ' FROM ' + @full_name + ';' AS comando
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(@full_name)

UNION ALL

SELECT
    '-- INSERT' AS bloco,
    'INSERT INTO ' + @full_name + ' (' +
    STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id) +
    ') VALUES (' +
    STRING_AGG('@' + c.name, ', ') WITHIN GROUP (ORDER BY c.column_id) +
    ');' AS comando
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(@full_name)
  AND c.is_identity = 0
  AND c.is_computed = 0

UNION ALL

SELECT
    '-- UPDATE' AS bloco,
    'UPDATE ' + @full_name + ' SET ' +
    STRING_AGG(QUOTENAME(c.name) + ' = @' + c.name, ', ') WITHIN GROUP (ORDER BY c.column_id) +
    ' WHERE <condicao>;' AS comando
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(@full_name)
  AND c.is_identity = 0
  AND c.is_computed = 0

UNION ALL

SELECT
    '-- DELETE' AS bloco,
    'DELETE FROM ' + @full_name + ' WHERE <condicao>;' AS comando;