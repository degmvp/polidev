tsql11.tsql
-- ============================================
-- T-SQL 11 - TRY CATCH
-- ============================================

BEGIN TRY

    SELECT 10 / 0 AS resultado;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS numero_erro,
        ERROR_MESSAGE() AS mensagem_erro,
        ERROR_LINE() AS linha_erro;

END CATCH;