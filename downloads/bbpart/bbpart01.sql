/*
===============================================================================
POLYDEV BLACK BELT
===============================================================================

Arquivo....: bbpart01.sql
Título.....: Big Data Partitioning Overview
Categoria..: bbpart

Objetivo:
Demonstrar os conceitos fundamentais de particionamento temporal para
ambientes SQL Server com grande volume de dados.

Estratégia:

1. Particionamento por DataEvento
2. Índice por DeviceID
3. Retenção de 3 meses online
4. Sliding Window
5. Arquivamento em Data Lake

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Big Data Partitioning Overview';
PRINT '=============================================================';
GO

/*
===============================================================================
CENÁRIO
===============================================================================

Empresa de telemetria com milhões de dispositivos.

Cada dispositivo envia eventos continuamente.

Exemplo:

100.000 dispositivos
1 evento por minuto

Resultado:

144 milhões de registros por dia

Mais de 52 bilhões por ano

===============================================================================
*/

DECLARE @Devices      BIGINT = 100000;
DECLARE @EventosMin   INT    = 1;

SELECT
    @Devices      AS TotalDispositivos,
    @EventosMin   AS EventosPorMinuto,
    (@Devices * 60 * 24) AS EventosPorDia;
GO

/*
===============================================================================
PROBLEMA
===============================================================================

Sem particionamento:

- Crescimento descontrolado
- Índices gigantes
- Backups maiores
- Consultas lentas
- DELETE de histórico inviável

Exemplo inadequado:

DELETE FROM dbo.Telemetria
WHERE DataEvento < DATEADD(MONTH,-3,GETDATE())

Em ambientes bilionários isso pode gerar:

- Locks
- Log gigante
- Longas janelas de manutenção

===============================================================================
*/

PRINT 'Problema identificado: crescimento contínuo de dados.';
GO

/*
===============================================================================
SOLUÇÃO
===============================================================================

Particionamento Temporal

DataEvento

2026-01
2026-02
2026-03
2026-04

Cada período torna-se uma partição lógica.

===============================================================================
*/

SELECT
    '2026-01' AS Particao01,
    '2026-02' AS Particao02,
    '2026-03' AS Particao03,
    '2026-04' AS Particao04;
GO

/*
===============================================================================
ESTRATÉGIA RECOMENDADA
===============================================================================

Partição:
    DataEvento

Índice:
    DeviceID + DataEvento

Consulta típica:

SELECT *
FROM dbo.Telemetria
WHERE DeviceID = 10001
AND DataEvento >= '2026-04-01'
AND DataEvento <  '2026-05-01'

Benefícios:

1. Partition Elimination
2. Index Seek
3. Menor leitura física
4. Melhor escalabilidade

===============================================================================
*/

PRINT 'Estratégia: Particionamento Temporal + Índice por Dispositivo';
GO

/*
===============================================================================
JANELA QUENTE (HOT DATA)
===============================================================================

Manter apenas:

Mês Atual
Mês -1
Mês -2

Exemplo:

Abril
Maio
Junho

Online no SQL Server

===============================================================================
*/

SELECT
    DATENAME(MONTH,DATEADD(MONTH,-2,GETDATE())) AS MesMenos2,
    DATENAME(MONTH,DATEADD(MONTH,-1,GETDATE())) AS MesMenos1,
    DATENAME(MONTH,GETDATE())                   AS MesAtual;
GO

/*
===============================================================================
JANELA FRIA (COLD DATA)
===============================================================================

Partições antigas:

Janeiro
Fevereiro
Março

Movidas para:

- Data Lake
- Parquet
- Azure Data Lake
- Amazon S3
- Hadoop

===============================================================================
*/

PRINT 'Dados históricos devem ser movidos para Data Lake.';
GO

/*
===============================================================================
SLIDING WINDOW
===============================================================================

Fluxo mensal:

1. Criar nova partição
2. Receber novos dados
3. Remover partição mais antiga
4. Exportar para Data Lake

Sem DELETE massivo.

===============================================================================
*/

PRINT 'Sliding Window elimina a necessidade de DELETE em massa.';
GO

/*
===============================================================================
ARQUITETURA FINAL
===============================================================================

                SQL SERVER

        +----------------------+
        | Ultimos 3 Meses      |
        | Dados Quentes        |
        +----------------------+
                  |
                  |
           Sliding Window
                  |
                  v

        +----------------------+
        | Data Lake            |
        | Historico Completo   |
        +----------------------+

===============================================================================
*/

PRINT 'Arquitetura validada.';
PRINT 'Próximo programa: bbpart02.sql';
GO