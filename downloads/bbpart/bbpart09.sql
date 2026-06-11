# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart09.sql
Título.....: Data Lake Export Strategy
Categoria..: bbpart

Objetivo:
Demonstrar a estratégia de exportação da partição antiga para Data Lake
após o SWITCH OUT para uma tabela staging.

Pré-requisitos:
bbpart08.sql -> dbo.Telemetria_Stage_Partition01

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Data Lake Export Strategy';
PRINT '=============================================================';
GO

# /*

# CONCEITO

Depois do SWITCH OUT, a partição antiga sai da tabela principal e passa para
uma tabela staging.

Essa staging representa um bloco histórico fechado.

Exemplo:

dbo.Telemetria_Stage_Partition01

Contém:
Dados anteriores a 2026-01-01

Destino:
Data Lake

Formatos comuns:
Parquet
CSV
Delta Lake
ORC

O SQL Server mantém dados quentes.
O Data Lake mantém dados frios.

===============================================================================
*/

PRINT 'Preparando estratégia de exportação para Data Lake.';
GO

# /*

# VALIDAÇÃO DA STAGING

*/

IF OBJECT_ID('dbo.Telemetria_Stage_Partition01','U') IS NULL
BEGIN
RAISERROR('Tabela staging não encontrada. Execute bbpart08.sql.',16,1);
RETURN;
END
GO

SELECT
COUNT(*) AS TotalLinhas,
MIN(DataEvento) AS DataInicial,
MAX(DataEvento) AS DataFinal
FROM dbo.Telemetria_Stage_Partition01;
GO

# /*

# METADADOS DO LOTE DE EXPORTAÇÃO

Antes de exportar, registre informações do lote:

1. Nome da tabela staging
2. Período exportado
3. Total de linhas
4. Data da exportação
5. Destino lógico no Data Lake

===============================================================================
*/

DECLARE
@TabelaStage SYSNAME = 'dbo.Telemetria_Stage_Partition01',
@DestinoLake NVARCHAR(4000) =
'datalake/telemetria/year=2025/month=12/',
@TotalLinhas BIGINT,
@DataInicial DATE,
@DataFinal DATE;

SELECT
@TotalLinhas = COUNT(*),
@DataInicial = MIN(DataEvento),
@DataFinal   = MAX(DataEvento)
FROM dbo.Telemetria_Stage_Partition01;

SELECT
@TabelaStage AS TabelaStage,
@DestinoLake AS DestinoDataLake,
@TotalLinhas AS TotalLinhas,
@DataInicial AS DataInicial,
@DataFinal AS DataFinal,
SYSDATETIME() AS DataExportacao;
GO

# /*

# ESTRATÉGIA DE CAMINHO NO DATA LAKE

Um bom Data Lake precisa de organização previsível.

Exemplo recomendado:

datalake/
telemetria/
year=2025/
month=12/
part-0001.parquet
part-0002.parquet

Vantagens:

1. Fácil leitura por Spark
2. Fácil filtro por ano e mês
3. Compatível com engines analíticas
4. Facilita auditoria e reprocessamento

===============================================================================
*/

SELECT
'datalake/telemetria/year=2025/month=12/' AS CaminhoRecomendado,
'Parquet' AS FormatoRecomendado,
'Partição histórica exportada do SQL Server' AS Observacao;
GO

# /*

# EXEMPLO CONCEITUAL COM BCP

BCP pode exportar dados para arquivo texto.

Exemplo fora do SQL Server:

bcp "SELECT * FROM SeuBanco.dbo.Telemetria_Stage_Partition01"
queryout "D:\EXPORT\telemetria_2025_12.csv"
-c -t, -T -S SEU_SERVIDOR

Depois o arquivo pode ser enviado para:

* Azure Data Lake
* Amazon S3
* Google Cloud Storage
* HDFS
* Storage local corporativo

Observação:
BCP exporta CSV/texto. Para Parquet, normalmente o processo passa por Spark,
ADF, Synapse, Databricks, Python ou outra ferramenta de engenharia de dados.

===============================================================================
*/

PRINT 'Exemplo conceitual de exportação com BCP documentado.';
GO

# /*

# EXEMPLO CONCEITUAL COM PYTHON

Pipeline externo:

1. Ler dados da staging
2. Converter para DataFrame
3. Gravar Parquet
4. Enviar para Data Lake
5. Registrar auditoria

Exemplo conceitual:

import pandas as pd
import pyodbc

conn = pyodbc.connect("DRIVER={ODBC Driver 18 for SQL Server};SERVER=.;DATABASE=SeuBanco;Trusted_Connection=yes;TrustServerCertificate=yes")

sql = "SELECT * FROM dbo.Telemetria_Stage_Partition01"

df = pd.read_sql(sql, conn)

df.to_parquet(
"datalake/telemetria/year=2025/month=12/part-0001.parquet",
index=False
)

===============================================================================
*/

PRINT 'Exemplo conceitual de exportação com Python documentado.';
GO

# /*

# TABELA DE AUDITORIA DE EXPORTAÇÃO

Em produção, registre cada partição exportada.

Isso permite saber:

1. O que foi exportado
2. Quando foi exportado
3. Quantas linhas foram exportadas
4. Para onde foi enviado
5. Se o processo foi validado

===============================================================================
*/

IF OBJECT_ID('dbo.Telemetria_Export_Audit','U') IS NULL
BEGIN
CREATE TABLE dbo.Telemetria_Export_Audit
(
ExportID       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
TabelaStage    SYSNAME NOT NULL,
DestinoLake    NVARCHAR(4000) NOT NULL,
TotalLinhas    BIGINT NOT NULL,
DataInicial    DATE NULL,
DataFinal      DATE NULL,
DataExportacao DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
StatusExport   VARCHAR(30) NOT NULL
);
END
GO

DECLARE
@TabelaStageAudit SYSNAME = 'dbo.Telemetria_Stage_Partition01',
@DestinoLakeAudit NVARCHAR(4000) =
'datalake/telemetria/year=2025/month=12/',
@TotalLinhasAudit BIGINT,
@DataInicialAudit DATE,
@DataFinalAudit DATE;

SELECT
@TotalLinhasAudit = COUNT(*),
@DataInicialAudit = MIN(DataEvento),
@DataFinalAudit   = MAX(DataEvento)
FROM dbo.Telemetria_Stage_Partition01;

INSERT INTO dbo.Telemetria_Export_Audit
(
TabelaStage,
DestinoLake,
TotalLinhas,
DataInicial,
DataFinal,
StatusExport
)
VALUES
(
@TabelaStageAudit,
@DestinoLakeAudit,
@TotalLinhasAudit,
@DataInicialAudit,
@DataFinalAudit,
'DOCUMENTED'
);
GO

# /*

# CONSULTA DE AUDITORIA

*/

SELECT
ExportID,
TabelaStage,
DestinoLake,
TotalLinhas,
DataInicial,
DataFinal,
DataExportacao,
StatusExport
FROM dbo.Telemetria_Export_Audit
ORDER BY ExportID DESC;
GO

# /*

# APÓS EXPORTAR COM SUCESSO

Depois que o arquivo estiver confirmado no Data Lake:

1. Validar contagem de linhas
2. Validar período exportado
3. Validar integridade do arquivo
4. Atualizar auditoria como EXPORTED
5. Truncar ou descartar a staging

Exemplo:

UPDATE dbo.Telemetria_Export_Audit
SET StatusExport = 'EXPORTED'
WHERE ExportID = @ExportID;

TRUNCATE TABLE dbo.Telemetria_Stage_Partition01;

===============================================================================
*/

PRINT 'Auditoria de exportação registrada.';
GO

# /*

# CONCEITO BLACK BELT

O Data Lake não é apenas depósito de arquivos.

Ele é a camada histórica da arquitetura.

SQL Server:
Dados quentes
Baixa latência
Consulta operacional
Últimos 3 meses

Data Lake:
Dados frios
Histórico completo
Baixo custo
Reprocessamento analítico

A estratégia correta evita transformar o SQL Server em um armazém infinito
de dados históricos.

O banco operacional deve permanecer enxuto.

O histórico deve ser preservado em camada apropriada.

===============================================================================
*/

PRINT 'Data Lake Export Strategy demonstrada com sucesso.';
PRINT 'Próximo programa: bbpart10.sql';
GO
