CREATE OR ALTER PROCEDURE dbo.bb_sp07_backup_checker
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.name AS database_name,
        MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS last_full_backup,
        MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS last_diff_backup,
        MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS last_log_backup
    FROM sys.databases d
    LEFT JOIN msdb.dbo.backupset b ON b.database_name = d.name
    GROUP BY d.name
    ORDER BY d.name;
END;
GO