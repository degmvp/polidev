CREATE OR ALTER VIEW dbo.bb_vw08_backup_status
AS
SELECT
    d.name AS database_name,
    MAX(b.backup_finish_date) AS last_backup
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b
    ON b.database_name = d.name
GROUP BY d.name;
GO