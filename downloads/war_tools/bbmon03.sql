bbmon03.sql
SELECT TOP 25
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.execution_count,
    qs.total_logical_reads / NULLIF(qs.execution_count,0) AS avg_logical_reads,
    qs.total_elapsed_time,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        CASE
            WHEN qs.statement_end_offset = -1
            THEN LEN(CONVERT(NVARCHAR(MAX), st.text))
            ELSE (qs.statement_end_offset - qs.statement_start_offset) / 2 + 1
        END
    ) AS sql_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_logical_reads DESC;