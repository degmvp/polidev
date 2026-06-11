# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart02.sql
Título.....: Temporal Partition Function
Categoria..: bbpart

Objetivo:
Demonstrar a criação de uma Partition Function temporal para suportar
ambientes Big Data com retenção controlada e Sliding Window.

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Temporal Partition Function';
PRINT '=============================================================';
GO

# /*

# O QUE É UMA PARTITION FUNCTION

A Partition Function define as fronteiras que serão utilizadas pelo
SQL Server para distribuir os dados entre as partições.

Ela não armazena dados.

Sua função é apenas definir os limites.

Exemplo:

Jan/2026
Fev/2026
Mar/2026
Abr/2026

Cada valor define uma nova fronteira.

===============================================================================
*/

PRINT 'Criando Partition Function temporal.';
GO

# /*

# REMOVENDO OBJETO CASO EXISTA

*/

IF EXISTS
(
SELECT 1
FROM sys.partition_functions
WHERE name = 'PF_Telemetria_Mensal'
)
BEGIN
PRINT 'Partition Function já existe.';
END
GO

# /*

# PARTITION FUNCTION

RANGE RIGHT

Partição 1 -> valores menores que 2026-01-01
Partição 2 -> Janeiro/2026
Partição 3 -> Fevereiro/2026
Partição 4 -> Março/2026
Partição 5 -> Abril/2026 em diante

===============================================================================
*/

CREATE PARTITION FUNCTION PF_Telemetria_Mensal
(
DATE
)
AS RANGE RIGHT
FOR VALUES
(
('2026-01-01'),
('2026-02-01'),
('2026-03-01'),
('2026-04-01')
);
GO

# /*

# VALIDAÇÃO

*/

SELECT
name,
fanout,
create_date
FROM sys.partition_functions
WHERE name = 'PF_Telemetria_Mensal';
GO

# /*

# POR QUE UTILIZAR RANGE RIGHT

RANGE RIGHT facilita a expansão da janela temporal.

Quando um novo mês surgir:

Julho/2026

Basta executar:

ALTER PARTITION FUNCTION PF_Telemetria_Mensal()
SPLIT RANGE ('2026-07-01');

Uma nova partição será criada automaticamente.

Essa abordagem é amplamente utilizada em ambientes de telemetria,
monitoramento, auditoria, IoT e Data Warehouse.

===============================================================================
*/

PRINT 'Exemplo de expansão futura da janela temporal.';
GO

/*
ALTER PARTITION FUNCTION PF_Telemetria_Mensal()
SPLIT RANGE ('2026-07-01');
GO
*/

# /*

# CONSULTANDO AS PARTIÇÕES

*/

SELECT
pf.name,
pf.fanout AS TotalParticoes
FROM sys.partition_functions pf
WHERE pf.name = 'PF_Telemetria_Mensal';
GO

# /*

# BENEFÍCIOS

1. Organização temporal dos dados

2. Base para Partition Elimination

3. Base para Sliding Window

4. Facilita retenção de dados

5. Permite integração com Data Lake

===============================================================================
*/

PRINT 'Partition Function criada com sucesso.';
PRINT 'Próximo programa: bbpart03.sql';
GO
