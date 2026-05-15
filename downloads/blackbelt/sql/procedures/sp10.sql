CREATE OR ALTER PROCEDURE dbo.bb_sp10_sql_em_execucao
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.session_id,
        r.status,
        r.command,
        r.cpu_time,
        r.total_elapsed_time,
        r.reads,
        r.writes,
        r.logical_reads,
        DB_NAME(r.database_id) AS database_name,
        SUBSTRING(
            txt.text,
            (r.statement_start_offset / 2) + 1,
            CASE 
                WHEN r.statement_end_offset = -1 
                THEN LEN(CONVERT(NVARCHAR(MAX), txt.text))
                ELSE (r.statement_end_offset - r.statement_start_offset) / 2 + 1
            END
        ) AS running_statement,
        txt.text AS full_sql_text
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) txt
    WHERE r.session_id <> @@SPID
    ORDER BY r.total_elapsed_time DESC;
END;
GO