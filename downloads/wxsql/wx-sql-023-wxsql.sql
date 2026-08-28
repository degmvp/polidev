# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart08.sql
Título.....: SWITCH OUT Operations
Categoria..: bbpart

Objetivo:
Demonstrar o conceito de SWITCH OUT para mover uma partição antiga da tabela
principal para uma tabela staging, preparando o envio ao Data Lake.

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
PRINT 'SWITCH OUT Operations';
PRINT '=============================================================';
GO

# /*

# CONCEITO

SWITCH OUT move uma partição inteira de uma tabela particionada para uma
tabela staging.

A operação é baseada em metadados.

Ela é muito mais rápida do que DELETE em massa.

Fluxo:

dbo.Telemetria
PARTITION 1
|
| SWITCH OUT
v

dbo.Telemetria_Stage_Partition01

Depois disso, a tabela staging pode ser exportada para o Data Lake.

===============================================================================
*/

PRINT 'Preparando demonstração de SWITCH OUT.';
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

# TABELA STAGING

Para SWITCH OUT funcionar, a tabela destino deve ser compatível com a tabela
origem.

Regras importantes:

1. Mesmas colunas
2. Mesmos tipos
3. Mesma nulabilidade
4. Índices compatíveis
5. Constraints compatíveis
6. Tabela destino vazia

Neste exemplo, criamos uma tabela staging para receber a partição antiga.

===============================================================================
*/

IF OBJECT_ID('dbo.Telemetria_Stage_Partition01','U') IS NOT NULL
BEGIN
DROP TABLE dbo.Telemetria_Stage_Partition01;
END
GO

CREATE TABLE dbo.Telemetria_Stage_Partition01
(
TelemetriaID BIGINT NOT NULL,
DeviceID     BIGINT NOT NULL,
DataEvento   DATE NOT NULL,
Temperatura  DECIMAL(10,2) NULL,
Latitude     DECIMAL(10,6) NULL,
Longitude    DECIMAL(10,6) NULL,
PayloadJson  NVARCHAR(MAX) NULL,

```
CONSTRAINT PK_Telemetria_Stage_Partition01
PRIMARY KEY CLUSTERED
(
    DataEvento,
    TelemetriaID
)
```

);
GO

# /*

# CHECK CONSTRAINT DA PARTIÇÃO

A partição 1 representa os dados menores que a primeira fronteira.

No bbpart02.sql, a primeira fronteira foi:

2026-01-01

Logo, a staging da partição 1 deve aceitar somente:

DataEvento < '2026-01-01'

Essa constraint ajuda o SQL Server a validar o SWITCH.

===============================================================================
*/

ALTER TABLE dbo.Telemetria_Stage_Partition01
ADD CONSTRAINT CK_Telemetria_Stage_Partition01
CHECK
(
DataEvento < '2026-01-01'
);
GO

# /*

# ÍNDICE COMPATÍVEL

A tabela principal possui o índice não clustered:

IX_Telemetria_DeviceID_DataEvento

Para que o SWITCH funcione, a staging precisa possuir índice compatível.

===============================================================================
*/

CREATE NONCLUSTERED INDEX IX_Telemetria_Stage_DeviceID_DataEvento
ON dbo.Telemetria_Stage_Partition01
(
DeviceID,
DataEvento
)
INCLUDE
(
Temperatura,
Latitude,
Longitude
);
GO

# /*

# SWITCH OUT

Este comando move a partição 1 da tabela principal para a staging.

A operação abaixo está comentada por segurança.

Antes de executar em produção, confirme:

1. A partição realmente contém apenas dados antigos
2. A staging está vazia
3. Índices e constraints estão compatíveis
4. Não existem foreign keys impedindo a operação
5. Existe backup ou plano de rollback

===============================================================================
*/

/*
ALTER TABLE dbo.Telemetria
SWITCH PARTITION 1
TO dbo.Telemetria_Stage_Partition01;
GO
*/

PRINT 'Comando SWITCH OUT preparado.';
GO

# /*

# VALIDAÇÃO APÓS SWITCH OUT

Após executar o SWITCH, valide:

1. Linhas removidas da partição original
2. Linhas presentes na staging
3. Período correto na staging

===============================================================================
*/

SELECT
'Tabela Principal' AS Origem,
$PARTITION.PF_Telemetria_Mensal(DataEvento) AS PartitionNumber,
COUNT(*) AS TotalLinhas,
MIN(DataEvento) AS DataInicial,
MAX(DataEvento) AS DataFinal
FROM dbo.Telemetria
GROUP BY $PARTITION.PF_Telemetria_Mensal(DataEvento)
UNION ALL
SELECT
'Staging',
NULL,
COUNT(*),
MIN(DataEvento),
MAX(DataEvento)
FROM dbo.Telemetria_Stage_Partition01
ORDER BY Origem, PartitionNumber;
GO

# /*

# PRÓXIMO PASSO

Depois do SWITCH OUT:

1. Exportar dbo.Telemetria_Stage_Partition01 para Data Lake
2. Validar arquivo no destino
3. Registrar auditoria da exportação
4. Truncar staging
5. Executar MERGE RANGE se a fronteira antiga puder ser removida

O Data Lake passa a ser o repositório histórico frio.

O SQL Server permanece enxuto com os dados quentes.

===============================================================================
*/

PRINT 'Após o SWITCH OUT, a staging está pronta para exportação.';
GO

# /*

# CONCEITO BLACK BELT

SWITCH OUT é o coração operacional da estratégia Sliding Window.

Sem ele, o DBA dependeria de DELETE massivo.

Com ele, o histórico sai da tabela principal por movimentação de metadados.

Arquitetura final:

SQL Server:
Últimos 3 meses online

Data Lake:
Histórico completo

SWITCH OUT:
Ponte entre dados quentes e dados frios

===============================================================================
*/

PRINT 'SWITCH OUT Operations demonstrado com sucesso.';
PRINT 'Próximo programa: bbpart09.sql';
GO
