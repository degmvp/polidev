# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart04.sql
Título.....: Partitioned Telemetry Table
Categoria..: bbpart

Objetivo:
Criar uma tabela de telemetria particionada por DataEvento usando a
Partition Scheme criada anteriormente.

Pré-requisitos:
bbpart02.sql -> PF_Telemetria_Mensal
bbpart03.sql -> PS_Telemetria_Mensal

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Partitioned Telemetry Table';
PRINT '=============================================================';
GO

# /*

# VALIDAÇÃO DOS OBJETOS DE PARTICIONAMENTO

*/

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

IF NOT EXISTS
(
SELECT 1
FROM sys.partition_schemes
WHERE name = 'PS_Telemetria_Mensal'
)
BEGIN
RAISERROR('Partition Scheme PS_Telemetria_Mensal não encontrada. Execute bbpart03.sql.',16,1);
RETURN;
END
GO

# /*

# CRIAÇÃO DA TABELA PARTICIONADA

A tabela será particionada pela coluna DataEvento.

Importante:
Para uma tabela particionada com índice clustered, a coluna de particionamento
deve fazer parte da chave do índice clustered.

Por isso, usamos:

PRIMARY KEY CLUSTERED
(
DataEvento,
TelemetriaID
)

Isso mantém os dados fisicamente organizados por tempo.

===============================================================================
*/

IF OBJECT_ID('dbo.Telemetria','U') IS NOT NULL
BEGIN
DROP TABLE dbo.Telemetria;
END
GO

CREATE TABLE dbo.Telemetria
(
TelemetriaID BIGINT IDENTITY(1,1) NOT NULL,
DeviceID     BIGINT NOT NULL,
DataEvento   DATE NOT NULL,
Temperatura  DECIMAL(10,2) NULL,
Latitude     DECIMAL(10,6) NULL,
Longitude    DECIMAL(10,6) NULL,
PayloadJson  NVARCHAR(MAX) NULL,

```
CONSTRAINT PK_Telemetria
PRIMARY KEY CLUSTERED
(
    DataEvento,
    TelemetriaID
)
ON PS_Telemetria_Mensal(DataEvento)
```

)
ON PS_Telemetria_Mensal(DataEvento)
TEXTIMAGE_ON [PRIMARY];
GO

# /*

# INSERINDO DADOS DE EXEMPLO

As datas abaixo foram escolhidas para cair em partições diferentes:

2025-12-20 -> partição OLD
2026-01-10 -> Janeiro
2026-02-15 -> Fevereiro
2026-03-20 -> Março
2026-04-05 -> Current

===============================================================================
*/

INSERT INTO dbo.Telemetria
(
DeviceID,
DataEvento,
Temperatura,
Latitude,
Longitude,
PayloadJson
)
VALUES
(10001,'2025-12-20',28.50,-7.115000,-34.861000,N'{"source":"polydev","event":"old"}'),
(10001,'2026-01-10',29.10,-7.116000,-34.862000,N'{"source":"polydev","event":"jan"}'),
(10002,'2026-02-15',30.20,-7.117000,-34.863000,N'{"source":"polydev","event":"feb"}'),
(10003,'2026-03-20',31.30,-7.118000,-34.864000,N'{"source":"polydev","event":"mar"}'),
(10001,'2026-04-05',32.40,-7.119000,-34.865000,N'{"source":"polydev","event":"current"}');
GO

# /*

# VALIDAÇÃO DA DISTRIBUIÇÃO POR PARTIÇÃO

A função $PARTITION permite identificar em qual partição cada linha foi gravada.

===============================================================================
*/

SELECT
$PARTITION.PF_Telemetria_Mensal(DataEvento) AS PartitionNumber,
TelemetriaID,
DeviceID,
DataEvento,
Temperatura
FROM dbo.Telemetria
ORDER BY PartitionNumber, DataEvento;
GO

# /*

# CONTAGEM DE LINHAS POR PARTIÇÃO

*/

SELECT
$PARTITION.PF_Telemetria_Mensal(DataEvento) AS PartitionNumber,
COUNT(*) AS TotalLinhas
FROM dbo.Telemetria
GROUP BY $PARTITION.PF_Telemetria_Mensal(DataEvento)
ORDER BY PartitionNumber;
GO

# /*

# VISÃO DO CATÁLOGO

*/

SELECT
t.name AS TableName,
i.name AS IndexName,
ps.name AS PartitionScheme,
pf.name AS PartitionFunction
FROM sys.tables t
INNER JOIN sys.indexes i
ON t.object_id = i.object_id
INNER JOIN sys.partition_schemes ps
ON i.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
ON ps.function_id = pf.function_id
WHERE t.name = 'Telemetria';
GO

# /*

# CONCEITO BLACK BELT

A tabela agora possui uma estrutura preparada para Big Data operacional:

1. Dados organizados temporalmente

2. Partições controladas por DataEvento

3. Base pronta para Partition Elimination

4. Base pronta para Sliding Window

5. Base pronta para retenção de 3 meses online

O próximo passo será criar o índice estratégico:

DeviceID + DataEvento

Esse índice permitirá localizar rapidamente eventos de um dispositivo
dentro da janela temporal correta.

===============================================================================
*/

PRINT 'Tabela particionada criada com sucesso.';
PRINT 'Próximo programa: bbpart05.sql';
GO
