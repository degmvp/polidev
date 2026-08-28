# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart10.sql
Título.....: Maintenance and Best Practices
Categoria..: bbpart

Objetivo:
Consolidar boas práticas de manutenção para tabelas particionadas em
ambientes SQL Server Big Data.

Pré-requisitos:
bbpart01.sql até bbpart09.sql

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Maintenance and Best Practices';
PRINT '=============================================================';
GO

# /*

# CONCEITO FINAL DA SÉRIE

Esta série demonstrou uma arquitetura para Big Data operacional:

1. Particionar por DataEvento
2. Indexar por DeviceID + DataEvento
3. Manter 3 meses online
4. Usar Sliding Window
5. Fazer SWITCH OUT para staging
6. Exportar histórico frio para Data Lake
7. Manter o SQL Server enxuto

===============================================================================
*/

PRINT 'Consolidando boas práticas de manutenção.';
GO

# /*

# VALIDAÇÃO DOS OBJETOS PRINCIPAIS

*/

IF OBJECT_ID('dbo.Telemetria','U') IS NULL
BEGIN
RAISERROR('Tabela dbo.Telemetria não encontrada. Execute os scripts anteriores.',16,1);
RETURN;
END
GO

# /*

1. MONITORAR LINHAS POR PARTIÇÃO
   ===============================================================================
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

2. MONITORAR ÍNDICES
   ===============================================================================
   */

SELECT
OBJECT_NAME(s.object_id) AS TableName,
i.name AS IndexName,
s.partition_number,
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
WHERE OBJECT_NAME(s.object_id) = 'Telemetria'
ORDER BY i.name, s.partition_number;
GO

# /*

3. MONITORAR TAMANHO POR PARTIÇÃO
   ===============================================================================
   */

SELECT
p.partition_number,
i.name AS IndexName,
au.type_desc,
SUM(au.total_pages) * 8.0 / 1024 AS TotalMB,
SUM(au.used_pages)  * 8.0 / 1024 AS UsedMB,
SUM(au.data_pages)  * 8.0 / 1024 AS DataMB
FROM sys.partitions p
INNER JOIN sys.indexes i
ON p.object_id = i.object_id
AND p.index_id = i.index_id
INNER JOIN sys.allocation_units au
ON p.hobt_id = au.container_id
WHERE p.object_id = OBJECT_ID('dbo.Telemetria')
GROUP BY
p.partition_number,
i.name,
au.type_desc
ORDER BY
p.partition_number,
i.name;
GO

# /*

4. VALIDAR PARTITION FUNCTION
   ===============================================================================
   */

SELECT
pf.name AS PartitionFunction,
pf.fanout AS TotalParticoes,
prv.boundary_id,
prv.value AS BoundaryValue
FROM sys.partition_functions pf
LEFT JOIN sys.partition_range_values prv
ON pf.function_id = prv.function_id
WHERE pf.name = 'PF_Telemetria_Mensal'
ORDER BY prv.boundary_id;
GO

# /*

5. VALIDAR PARTITION SCHEME
   ===============================================================================
   */

SELECT
ps.name AS PartitionScheme,
dds.destination_id AS PartitionNumber,
fg.name AS FilegroupName
FROM sys.partition_schemes ps
INNER JOIN sys.destination_data_spaces dds
ON ps.data_space_id = dds.partition_scheme_id
INNER JOIN sys.filegroups fg
ON dds.data_space_id = fg.data_space_id
WHERE ps.name = 'PS_Telemetria_Mensal'
ORDER BY dds.destination_id;
GO

# /*

6. BOAS PRÁTICAS
   ===============================================================================

A. Particionar por tempo

Use DataEvento, DataCriacao, DataMovimento ou outra coluna temporal.

Evite particionar por DeviceID, ClienteID ou SensorID quando houver alta
cardinalidade.

B. Manter índices alinhados

Sempre que possível, mantenha os índices no mesmo Partition Scheme da tabela.

C. Usar faixas de datas nos filtros

Bom:

WHERE DataEvento >= '2026-01-01'
AND   DataEvento <  '2026-02-01'

Ruim:

WHERE YEAR(DataEvento) = 2026

D. Evitar DELETE massivo

Use SWITCH OUT para remover partições inteiras.

E. Controlar número de partições

O limite técnico não deve ser tratado como meta operacional.

F. Criar partições futuras antes da virada do mês

Evite receber dados novos sem a próxima fronteira preparada.

G. Exportar histórico antes de remover a partição

Nunca descarte dados sem validação no Data Lake.

===============================================================================
*/

PRINT 'Boas práticas documentadas.';
GO

# /*

7. CHECKLIST MENSAL DE OPERAÇÃO
   ===============================================================================

8. Verificar partição atual

9. Criar próxima fronteira com SPLIT RANGE

10. Definir NEXT USED no Partition Scheme

11. Identificar partição antiga

12. SWITCH OUT para staging

13. Exportar staging para Data Lake

14. Validar contagem e período

15. Registrar auditoria

16. Truncar staging

17. Avaliar MERGE RANGE da fronteira antiga

18. Reorganizar ou reconstruir índices se necessário

19. Atualizar estatísticas

===============================================================================
*/

SELECT
1 AS Ordem,
'Verificar partição atual' AS Checklist
UNION ALL SELECT
2,
'Criar próxima fronteira com SPLIT RANGE'
UNION ALL SELECT
3,
'Definir NEXT USED no Partition Scheme'
UNION ALL SELECT
4,
'Identificar partição antiga'
UNION ALL SELECT
5,
'SWITCH OUT para staging'
UNION ALL SELECT
6,
'Exportar staging para Data Lake'
UNION ALL SELECT
7,
'Validar contagem e período'
UNION ALL SELECT
8,
'Registrar auditoria'
UNION ALL SELECT
9,
'Truncar staging'
UNION ALL SELECT
10,
'Avaliar MERGE RANGE da fronteira antiga'
UNION ALL SELECT
11,
'Manutenção de índices'
UNION ALL SELECT
12,
'Atualizar estatísticas';
GO

# /*

8. COMANDOS MODELO
   ===============================================================================
   */

PRINT 'Modelo para criar próxima partição:';
GO

/*
ALTER PARTITION SCHEME PS_Telemetria_Mensal
NEXT USED FG_TELEMETRIA_CURRENT;
GO

ALTER PARTITION FUNCTION PF_Telemetria_Mensal()
SPLIT RANGE ('2026-05-01');
GO
*/

PRINT 'Modelo para remover partição antiga:';
GO

/*
ALTER TABLE dbo.Telemetria
SWITCH PARTITION 1
TO dbo.Telemetria_Stage_Partition01;
GO
*/

PRINT 'Modelo para remover fronteira antiga após arquivamento:';
GO

/*
ALTER PARTITION FUNCTION PF_Telemetria_Mensal()
MERGE RANGE ('2026-01-01');
GO
*/

# /*

9. ALERTAS IMPORTANTES
   ===============================================================================

10. SWITCH exige estruturas compatíveis entre origem e destino

11. CHECK CONSTRAINT deve representar corretamente a faixa da staging

12. Índices não alinhados podem impedir ou dificultar operações

13. Foreign Keys podem bloquear SWITCH

14. SPLIT e MERGE em partições com dados podem ser caros

15. Teste sempre em homologação antes de produção

16. Mantenha auditoria de exportação para Data Lake

17. Não transforme o SQL Server em Data Lake

===============================================================================
*/

PRINT 'Alertas operacionais registrados.';
GO

# /*

10. VISÃO FINAL
    ===============================================================================
    */

SELECT
'SQL Server' AS Camada,
'Últimos 3 meses' AS Retencao,
'Baixa latência e consulta operacional' AS Papel
UNION ALL
SELECT
'Data Lake',
'Histórico completo',
'Armazenamento frio, análise e reprocessamento';
GO

# /*

# ENCERRAMENTO

A estratégia correta para telemetria, IoT, auditoria, logs e Big Data
operacional no SQL Server é:

Particionamento Temporal
+
Índice por Dispositivo
+
Sliding Window
+
Data Lake

Essa combinação reduz custo, melhora manutenção e mantém performance
sem sacrificar histórico.

===============================================================================
*/

PRINT 'Maintenance and Best Practices concluído.';
PRINT 'Série bbpart01.sql até bbpart10.sql finalizada.';
GO
