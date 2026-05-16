bbmon02.sql
SELECT
    r.session_id,
    r.blocking_session_id,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    DB_NAME(r.database_id) AS database_name,
    s.login_name,
    s.host_name,
    s.program_name
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
    ON s.session_id = r.session_id
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;