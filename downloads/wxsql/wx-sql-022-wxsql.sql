# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart07.sql
Título.....: Sliding Window Retention
Categoria..: bbpart

Objetivo:
Demonstrar a estratégia de retenção com Sliding Window para manter somente
3 meses online no SQL Server.

Pré-requisitos:
bbpart02.sql -> PF_Telemetria_Mensal
bbpart03.sql -> PS_Telemetria_Mensal
bbpart04.sql -> dbo.Telemetria

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Sliding Window Retention';
PRINT '=============================================================';
GO

# /*

# CONCEITO

Sliding Window é a técnica usada para controlar retenção em tabelas
particionadas.

Neste projeto:

SQL Server:
Mantém 3 meses online

Data Lake:
Recebe o histórico frio

Fluxo mensal:

1. Criar nova partição futura
2. Receber novos dados
3. Identificar partição mais antiga
4. Fazer SWITCH OUT para tabela staging
5. Exportar staging para Data Lake
6. Remover ou arquivar staging

Sem DELETE massivo.

===============================================================================
*/

PRINT 'Estratégia: manter 3 meses online e mover histórico para Data Lake.';
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

# ESTADO ATUAL DAS PARTIÇÕES

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

# JANELA QUENTE

Exemplo didático da série:

Dados online:
Janeiro/2026
Fevereiro/2026
Março/2026

Nova entrada:
Abril/2026

Partição antiga:
Antes de Janeiro/2026

Destino:
Data Lake

===============================================================================
*/

DECLARE
@MesAtual       DATE = '2026-04-01',
@MesMenos1      DATE = '2026-03-01',
@MesMenos2      DATE = '2026-02-01',
@MesMenos3      DATE = '2026-01-01',
@ProximoMes     DATE = '2026-05-01';

SELECT
@MesMenos3  AS InicioJanela,
@MesMenos2  AS Mes02,
@MesMenos1  AS Mes03,
@MesAtual   AS MesAtual,
@ProximoMes AS ProximaParticao;
GO

# /*

# CRIANDO PRÓXIMA FRONTEIRA

Antes de receber um novo mês, o DBA prepara a próxima fronteira.

Com RANGE RIGHT, cada SPLIT RANGE cria uma nova janela.

Observação:
Este comando está comentado para evitar erro caso a fronteira já exista.

===============================================================================
*/

/*
ALTER PARTITION SCHEME PS_Telemetria_Mensal
NEXT USED FG_TELEMETRIA_CURRENT;
GO

ALTER PARTITION FUNCTION PF_Telemetria_Mensal()
SPLIT RANGE ('2026-05-01');
GO
*/

PRINT 'Nova fronteira preparada conceitualmente para 2026-05-01.';
GO

# /*

# IDENTIFICANDO PARTIÇÕES CANDIDATAS A ARQUIVAMENTO

Tudo antes do início da janela quente deve sair do SQL Server operacional.

Neste exemplo:

Janela quente começa em 2026-01-01.

Dados anteriores a essa data são candidatos ao Data Lake.

===============================================================================
*/

DECLARE @InicioJanelaQuente DATE = '2026-01-01';

SELECT
$PARTITION.PF_Telemetria_Mensal(DataEvento) AS PartitionNumber,
COUNT(*) AS TotalLinhas,
MIN(DataEvento) AS DataInicial,
MAX(DataEvento) AS DataFinal
FROM dbo.Telemetria
WHERE DataEvento < @InicioJanelaQuente
GROUP BY $PARTITION.PF_Telemetria_Mensal(DataEvento)
ORDER BY PartitionNumber;
GO

# /*

# POR QUE NÃO USAR DELETE

Exemplo ruim:

DELETE FROM dbo.Telemetria
WHERE DataEvento < '2026-01-01';

Em tabela bilionária isso pode causar:

1. Crescimento enorme do transaction log
2. Locks prolongados
3. Bloqueios em produção
4. Alto consumo de I/O
5. Janela de manutenção imprevisível

Sliding Window evita esse padrão.

===============================================================================
*/

PRINT 'Evite DELETE massivo em tabelas particionadas de grande volume.';
GO

# /*

# FLUXO CORRETO

O fluxo ideal será detalhado no bbpart08.sql:

ALTER TABLE dbo.Telemetria
SWITCH PARTITION 1
TO dbo.Telemetria_Stage_Partition01;

Depois:

1. Exportar dbo.Telemetria_Stage_Partition01 para Data Lake
2. Validar arquivo exportado
3. Truncar ou descartar staging
4. Fazer MERGE da fronteira antiga se necessário

===============================================================================
*/

PRINT 'Fluxo correto: SWITCH OUT antes de remover histórico.';
GO

# /*

# VISÃO OPERACIONAL

*/

SELECT
'SQL Server' AS Camada,
'Últimos 3 meses' AS Retencao,
'Dados quentes para consulta operacional' AS Finalidade
UNION ALL
SELECT
'Data Lake',
'Histórico completo',
'Dados frios para análise, auditoria e reprocessamento';
GO

# /*

# CONCEITO BLACK BELT

Sliding Window transforma retenção em operação de metadados.

Em vez de apagar bilhões de linhas, o DBA move uma partição inteira.

Arquitetura recomendada:

1. Particionar por DataEvento
2. Criar índices alinhados
3. Manter 3 meses online
4. Fazer SWITCH OUT da partição antiga
5. Exportar para Data Lake
6. Manter histórico frio fora do SQL Server

Esse é o ponto onde particionamento deixa de ser apenas performance
e passa a ser estratégia de arquitetura.

===============================================================================
*/

PRINT 'Sliding Window Retention demonstrada com sucesso.';
PRINT 'Próximo programa: bbpart08.sql';
GO
