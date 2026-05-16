bbmon09.sql
SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    r.reads,
    r.writes,
    r.logical_reads,
    DB_NAME(r.database_id) AS database_name,
    s.login_name,
    s.host_name,
    s.program_name,
    txt.text AS sql_text
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
    ON s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) txt
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;