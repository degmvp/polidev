tsql12.tsql
-- ============================================
-- T-SQL 12 - TRANSACTION
-- ============================================

BEGIN TRANSACTION;

BEGIN TRY

    UPDATE contas
    SET saldo = saldo - 100
    WHERE id_conta = 1;

    UPDATE contas
    SET saldo = saldo + 100
    WHERE id_conta = 2;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    SELECT ERROR_MESSAGE() AS erro;

END CATCH;