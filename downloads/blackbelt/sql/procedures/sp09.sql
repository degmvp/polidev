CREATE OR ALTER PROCEDURE dbo.bb_sp09_sessoes_abertas
AS
BEGIN
    SET NOCOUNT ON;

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
        logical_reads,
        login_time,
        last_request_start_time,
        last_request_end_time
    FROM sys.dm_exec_sessions
    WHERE is_user_process = 1
    ORDER BY login_time DESC;
END;
GO