bbmon10.sql
SELECT
    GETDATE() AS snapshot_time,
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('ProductVersion') AS product_version,
    SERVERPROPERTY('Edition') AS edition,
    SERVERPROPERTY('EngineEdition') AS engine_edition;

SELECT
    name,
    state_desc,
    recovery_model_desc,
    compatibility_level,
    create_date
FROM sys.databases
ORDER BY name;

SELECT TOP 10
    wait_type,
    wait_time_ms,
    waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE 'SLEEP%'
ORDER BY wait_time_ms DESC;

SELECT
    COUNT(*) AS active_user_sessions
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;