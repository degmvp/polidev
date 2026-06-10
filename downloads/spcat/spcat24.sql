/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat24.sql
Título..........: Index Series - LOB Data in Index Keys
Procedure.......: poly_cat_LobInIndexKeys
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Identificar índices que têm colunas do tipo LOB (VARCHAR(MAX), NVARCHAR(MAX), VARBINARY(MAX), XML)
fazendo parte da CHAVE do índice (não como coluna inclusa). 
Isso limita o tamanho máximo do índice, impede certos tipos de reconstrução ONLINE e destrói performance.

Aplicações:
- Auditoria de design de índices críticos
- Resolução de erros de criação de índice (limite de 900 bytes)
- Otimização de I/O

Catálogo utilizado:
sys.indexes
sys.index_columns
sys.columns
sys.types
sys.tables
sys.schemas

Execução:
EXEC poly_cat_LobInIndexKeys;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_LobInIndexKeys
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        c.name AS OffendingColumn,
        ty.name AS DataType
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE ic.is_included_column = 0 -- É chave
      AND c.max_length = -1         -- Flag para tipos MAX/LOB
      AND i.is_primary_key = 0
    ORDER BY s.name, t.name, i.name;
END;
GO

EXEC poly_cat_LobInIndexKeys;
GO
