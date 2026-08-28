tsql04.tsql
-- ============================================
-- T-SQL 04 - CTE Recursiva
-- ============================================

WITH numeros AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numeros
    WHERE n < 10
)
SELECT n
FROM numeros
OPTION (MAXRECURSION 10);