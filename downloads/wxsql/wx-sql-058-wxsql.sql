CREATE OR ALTER PROCEDURE dbo.bb_sp08_locks_ativos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.request_session_id AS session_id,
        DB_NAME(l.resource_database_id) AS database_name,
        l.resource_type,
        l.request_mode,
        l.request_status,
        s.host_name,
        s.program_name,
        s.login_name
    FROM sys.dm_tran_locks l
    LEFT JOIN sys.dm_exec_sessions s
        ON s.session_id = l.request_session_id
    ORDER BY l.request_session_id, l.resource_type;
END;
GO