2. CTE Recursiva
Usada para hierarquias, árvores, organogramas e estruturas pai-filho.

WITH RECURSIVE hierarquia AS (
    SELECT id, nome, gerente_id, 1 AS nivel
    FROM funcionarios
    WHERE gerente_id IS NULL

    UNION ALL

    SELECT f.id, f.nome, f.gerente_id, h.nivel + 1
    FROM funcionarios f
    JOIN hierarquia h ON f.gerente_id = h.id
)
SELECT *
FROM hierarquia;