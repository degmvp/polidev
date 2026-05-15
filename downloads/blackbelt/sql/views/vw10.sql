CREATE OR ALTER VIEW dbo.bb_vw10_resumo_banco
AS
SELECT
    DB_NAME() AS database_name,
    (
        SELECT COUNT(*)
        FROM sys.tables
    ) AS total_tables,
    (
        SELECT COUNT(*)
        FROM sys.views
    ) AS total_views,
    (
        SELECT COUNT(*)
        FROM sys.procedures
    ) AS total_procedures,
    (
        SELECT COUNT(*)
        FROM sys.objects
        WHERE type IN ('FN','IF','TF')
    ) AS total_functions;
GO