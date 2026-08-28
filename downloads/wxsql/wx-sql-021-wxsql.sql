# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart06.sql
Título.....: Partition Elimination
Categoria..: bbpart

Objetivo:
Demonstrar como o SQL Server elimina partições durante consultas que utilizam
a coluna de particionamento no predicado.

Pré-requisitos:
bbpart02.sql -> PF_Telemetria_Mensal
bbpart04.sql -> dbo.Telemetria
bbpart05.sql -> IX_Telemetria_DeviceID_DataEvento

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Partition Elimination';
PRINT '=============================================================';
GO

# /*

# VALIDAÇÃO DOS OBJETOS

*/

IF OBJECT_ID('dbo.Telemetria','U') IS NULL
BEGIN
RAISERROR('Tabela dbo.Telemetria não encontrada. Execute bbpart04.sql.',16,1);
RETURN;
END
GO

IF NOT EXISTS
(
SELECT 1
FROM sys.partition_functions
WHERE name = 'PF_Telemetria_Mensal'
)
BEGIN
RAISERROR('Partition Function PF_Telemetria_Mensal não encontrada. Execute bbpart02.sql.',16,1);
RETURN;
END
GO

# /*

# CONCEITO

Partition Elimination ocorre quando o otimizador consegue identificar que
apenas algumas partições precisam ser lidas.

Isso acontece quando o predicado da consulta utiliza a coluna de particionamento.

Neste projeto:

Coluna de particionamento:
DataEvento

Consulta ideal:
WHERE DataEvento >= '2026-02-01'
AND DataEvento <  '2026-03-01'

O SQL Server não precisa ler todas as partições.

Ele acessa somente a partição correspondente ao período solicitado.

===============================================================================
*/

PRINT 'Demonstrando Partition Elimination.';
GO

# /*

# MAPEANDO AS LINHAS POR PARTIÇÃO

*/

SELECT
$PARTITION.PF_Telemetria_Mensal(DataEvento) AS PartitionNumber,
COUNT(*) AS TotalLinhas,
MIN(DataEvento) AS DataInicial,
MAX(DataEvento) AS DataFinal
FROM dbo.Telemetria
GROUP BY $PARTITION.PF_Telemetria_Mensal(DataEvento)
ORDER BY PartitionNumber;
GO

# /*

# CONSULTA COM PARTITION ELIMINATION

Esta consulta utiliza DataEvento de forma direta.

O otimizador consegue eliminar partições fora da faixa.

===============================================================================
*/

SELECT
DeviceID,
DataEvento,
Temperatura,
Latitude,
Longitude
FROM dbo.Telemetria
WHERE DataEvento >= '2026-02-01'
AND DataEvento <  '2026-03-01';
GO

# /*

# CONSULTA COM DEVICEID + DATAEVENTO

Este é o padrão mais eficiente da série:

1. DataEvento elimina partições
2. DeviceID busca o dispositivo dentro da faixa
3. Índice IX_Telemetria_DeviceID_DataEvento ajuda a localizar o dado

===============================================================================
*/

SELECT
DeviceID,
DataEvento,
Temperatura,
Latitude,
Longitude
FROM dbo.Telemetria
WHERE DeviceID = 10002
AND DataEvento >= '2026-02-01'
AND DataEvento <  '2026-03-01';
GO

# /*

# CONSULTA RUIM

Sem DataEvento no filtro, o SQL Server não consegue eliminar partições.

Mesmo com DeviceID, todas as partições podem precisar ser avaliadas.

Em Big Data, isso pode ser extremamente caro.

===============================================================================
*/

SELECT
DeviceID,
DataEvento,
Temperatura
FROM dbo.Telemetria
WHERE DeviceID = 10001;
GO

# /*

# CONSULTA RUIM COM FUNÇÃO NA COLUNA

Evite aplicar função diretamente na coluna de particionamento.

Exemplo ruim:

WHERE YEAR(DataEvento) = 2026

Isso pode impedir o uso eficiente da eliminação de partições e prejudicar
o plano de execução.

Prefira sempre faixas abertas e fechadas:

DataEvento >= '2026-01-01'
AND DataEvento <  '2027-01-01'

===============================================================================
*/

SELECT
DeviceID,
DataEvento,
Temperatura
FROM dbo.Telemetria
WHERE YEAR(DataEvento) = 2026;
GO

# /*

# FORMA CORRETA

*/

SELECT
DeviceID,
DataEvento,
Temperatura
FROM dbo.Telemetria
WHERE DataEvento >= '2026-01-01'
AND DataEvento <  '2027-01-01';
GO

# /*

# VALIDAÇÃO COM $PARTITION

A função $PARTITION mostra quais partições correspondem às datas testadas.

===============================================================================
*/

SELECT
'2025-12-20' AS DataTeste,
$PARTITION.PF_Telemetria_Mensal(CONVERT(DATE,'2025-12-20')) AS PartitionNumber
UNION ALL
SELECT
'2026-01-10',
$PARTITION.PF_Telemetria_Mensal(CONVERT(DATE,'2026-01-10'))
UNION ALL
SELECT
'2026-02-15',
$PARTITION.PF_Telemetria_Mensal(CONVERT(DATE,'2026-02-15'))
UNION ALL
SELECT
'2026-03-20',
$PARTITION.PF_Telemetria_Mensal(CONVERT(DATE,'2026-03-20'))
UNION ALL
SELECT
'2026-04-05',
$PARTITION.PF_Telemetria_Mensal(CONVERT(DATE,'2026-04-05'));
GO

# /*

# CONCEITO BLACK BELT

Partition Elimination é o maior ganho prático do particionamento.

Sem ela, o particionamento vira apenas organização física.

Com ela, o SQL Server reduz drasticamente o volume de dados avaliado.

A regra de ouro:

Sempre filtrar pela coluna de particionamento.

Neste projeto:

DataEvento sempre deve aparecer nos filtros principais.

Modelo recomendado:

WHERE DeviceID = @DeviceID
AND DataEvento >= @DataInicial
AND DataEvento <  @DataFinal

===============================================================================
*/

PRINT 'Partition Elimination demonstrada com sucesso.';
PRINT 'Próximo programa: bbpart07.sql';
GO
