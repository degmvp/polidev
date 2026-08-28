CREATE OR ALTER PROCEDURE dbo.bb_sp11_top_procedures_cpu
    @top INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top)
        DB_NAME(database_id) AS database_name,
        OBJECT_SCHEMA_NAME(object_id, database_id) AS schema_name,
        OBJECT_NAME(object_id, database_id) AS procedure_name,
        execution_count,
        total_worker_time AS total_cpu,
        total_worker_time / NULLIF(execution_count,0) AS avg_cpu,
        total_elapsed_time,
        last_execution_time
    FROM sys.dm_exec_procedure_stats
    ORDER BY total_worker_time DESC;
END;
GO