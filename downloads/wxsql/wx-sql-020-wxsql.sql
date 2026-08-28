# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart05.sql
Título.....: DeviceID Index Strategy
Categoria..: bbpart

Objetivo:
Criar e demonstrar a estratégia de índice por dispositivo em uma tabela
particionada temporalmente.

Pré-requisito:
bbpart04.sql -> dbo.Telemetria

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'DeviceID Index Strategy';
PRINT '=============================================================';
GO

# /*

# VALIDAÇÃO DA TABELA

*/

IF OBJECT_ID('dbo.Telemetria','U') IS NULL
BEGIN
RAISERROR('Tabela dbo.Telemetria não encontrada. Execute bbpart04.sql.',16,1);
RETURN;
END
GO

# /*

# CONCEITO

Particionamento não substitui índice.

O particionamento reduz o universo de leitura pela faixa temporal.

O índice localiza rapidamente os registros dentro da faixa selecionada.

Estratégia:

Partição:
DataEvento

Índice:
DeviceID + DataEvento

Consulta típica:

WHERE DeviceID = 10001
AND DataEvento >= '2026-01-01'
AND DataEvento <  '2026-02-01'

Resultado desejado:

1. Partition Elimination pela DataEvento
2. Index Seek pelo DeviceID
3. Leitura reduzida
4. Melhor plano de execução

===============================================================================
*/

PRINT 'Criando índice estratégico DeviceID + DataEvento.';
GO

# /*

# REMOVENDO ÍNDICE CASO EXISTA

*/

IF EXISTS
(
SELECT 1
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Telemetria')
AND name = 'IX_Telemetria_DeviceID_DataEvento'
)
BEGIN
DROP INDEX IX_Telemetria_DeviceID_DataEvento
ON dbo.Telemetria;
END
GO

# /*

# ÍNDICE NÃO CLUSTERED

Este índice atende consultas que começam pelo DeviceID e filtram por período.

A coluna DataEvento também participa do índice para permitir busca eficiente
dentro da janela temporal.

As colunas Temperatura, Latitude e Longitude entram como INCLUDE para evitar
lookup em consultas analíticas simples.

===============================================================================
*/

CREATE NONCLUSTERED INDEX IX_Telemetria_DeviceID_DataEvento
ON dbo.Telemetria
(
DeviceID,
DataEvento
)
INCLUDE
(
Temperatura,
Latitude,
Longitude
)
ON PS_Telemetria_Mensal(DataEvento);
GO

# /*

# VALIDAÇÃO DO ÍNDICE

*/

SELECT
i.name AS IndexName,
i.type_desc AS IndexType,
ps.name AS PartitionScheme,
pf.name AS PartitionFunction
FROM sys.indexes i
INNER JOIN sys.partition_schemes ps
ON i.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
ON ps.function_id = pf.function_id
WHERE i.object_id = OBJECT_ID('dbo.Telemetria')
AND i.name = 'IX_Telemetria_DeviceID_DataEvento';
GO

# /*

# CONSULTA TÍPICA POR DISPOSITIVO

*/

SELECT
DeviceID,
DataEvento,
Temperatura,
Latitude,
Longitude
FROM dbo.Telemetria
WHERE DeviceID = 10001
AND DataEvento >= '2026-01-01'
AND DataEvento <  '2026-02-01';
GO

# /*

# CONSULTA EM JANELA DE 3 MESES

Este é o padrão operacional do projeto:

Manter os últimos 3 meses online no SQL Server.

O Data Lake recebe o histórico frio.

===============================================================================
*/

SELECT
DeviceID,
DataEvento,
Temperatura,
Latitude,
Longitude
FROM dbo.Telemetria
WHERE DeviceID = 10001
AND DataEvento >= '2026-01-01'
AND DataEvento <  '2026-04-01'
ORDER BY DataEvento;
GO

# /*

# ESTATÍSTICAS DE ÍNDICE

*/

SELECT
OBJECT_NAME(s.object_id) AS TableName,
i.name AS IndexName,
s.index_type_desc,
s.avg_fragmentation_in_percent,
s.page_count
FROM sys.dm_db_index_physical_stats
(
DB_ID(),
OBJECT_ID('dbo.Telemetria'),
NULL,
NULL,
'LIMITED'
) s
INNER JOIN sys.indexes i
ON s.object_id = i.object_id
AND s.index_id = i.index_id
WHERE i.name = 'IX_Telemetria_DeviceID_DataEvento';
GO

# /*

# CONCEITO BLACK BELT

Para Big Data operacional, a combinação correta é:

1. Particionamento temporal para eliminar partições

2. Índice por DeviceID para localizar o dispositivo

3. DataEvento no índice para manter a busca dentro do período

4. INCLUDE para evitar leituras extras

5. Sliding Window para remover histórico sem DELETE massivo

O erro comum é tentar particionar por DeviceID.

Isso cria milhares ou milhões de partições e destrói a manutenção.

O desenho correto é:

Particionar por tempo.
Indexar pelo identificador de negócio.

===============================================================================
*/

PRINT 'Índice DeviceID + DataEvento criado com sucesso.';
PRINT 'Próximo programa: bbpart06.sql';
GO
