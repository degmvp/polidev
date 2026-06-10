/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER (SÉRIE: INDEX & PERFORMANCE)

Arquivo.........: spcat30.sql
Título..........: Index Series - Statistics Without Indexes
Procedure.......: poly_cat_StatsWithoutIndexes
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Encontrar estatísticas criadas manualmente ou automaticamente pelo SQL Server que NÃO estão 
associadas a um índice. O otimizador usa essas estatísticas para gerar planos de execução, 
mas sem um índice, a consulta fará um Table Scan ou Index Scan improvável de ser performático.

Aplicações:
- Otimização de consultas (indicador de onde faltam índices)
- Entender o comportamento do Otimizador de Querys
- Limpeza de estatísticas órfãs

Catálogo utilizado:
sys.stats
sys.stats_columns
sys.columns
sys.tables
sys.schemas

Execução:
EXEC poly_cat_StatsWithoutIndexes;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_StatsWithoutIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        st.name AS StatisticName,
        c.name AS ColumnName,
        st.auto_created AS WasAutoCreated,
        st.user_created AS WasUserCreated
    FROM sys.stats st
    INNER JOIN sys.stats_columns sc ON st.object_id = sc.object_id AND st.stats_id = sc.stats_id
    INNER JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
    INNER JOIN sys.tables t ON st.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE NOT EXISTS (
        -- Verifica se não existe índice associado a esta estatística
        SELECT 1 
        FROM sys.indexes i 
        WHERE i.object_id = st.object_id 
          AND i.index_id = st.stats_id
    )
    AND t.is_ms_shipped = 0
    ORDER BY s.name, t.name, st.name;
END;
GO
