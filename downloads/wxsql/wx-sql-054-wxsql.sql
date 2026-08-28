CREATE OR ALTER PROCEDURE dbo.bb_sp04_estatisticas_tabelas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SCHEMA_NAME(t.schema_id) AS schema_name,
        t.name AS table_name,
        st.name AS statistic_name,
        st.auto_created,
        st.user_created,
        st.no_recompute,
        STATS_DATE(st.object_id, st.stats_id) AS last_updated
    FROM sys.stats st
    INNER JOIN sys.tables t ON t.object_id = st.object_id
    ORDER BY schema_name, table_name, statistic_name;
END;
GO