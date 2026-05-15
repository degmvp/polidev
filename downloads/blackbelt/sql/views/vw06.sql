CREATE OR ALTER VIEW dbo.bb_vw06_sessoes_ativas
AS
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    cpu_time,
    memory_usage,
    reads,
    writes,
    login_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;
GO