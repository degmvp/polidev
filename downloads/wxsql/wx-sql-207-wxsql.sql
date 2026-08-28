CREATE OR ALTER VIEW dbo.bb_vw07_jobs_sqlserver
AS
SELECT
    job_id,
    name,
    enabled,
    date_created,
    date_modified
FROM msdb.dbo.sysjobs;
GO