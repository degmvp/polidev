tsql15.tsql
-- ============================================
-- T-SQL 15 - BITWISE FLAGS
-- ============================================

-- 1 = leitura
-- 2 = escrita
-- 4 = exclusao
-- 8 = administrador

DECLARE @permissao INT = 1 | 2 | 8;

SELECT
    @permissao AS valor_binario,
    CASE WHEN (@permissao & 1) = 1 THEN 'SIM' ELSE 'NAO' END AS pode_ler,
    CASE WHEN (@permissao & 2) = 2 THEN 'SIM' ELSE 'NAO' END AS pode_escrever,
    CASE WHEN (@permissao & 4) = 4 THEN 'SIM' ELSE 'NAO' END AS pode_excluir,
    CASE WHEN (@permissao & 8) = 8 THEN 'SIM' ELSE 'NAO' END AS administrador;