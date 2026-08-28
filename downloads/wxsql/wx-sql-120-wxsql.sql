# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL10AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Fabric (Espelhamento Nativo e Analytics Sem ETL)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O maior inimigo da inteligência de negócios sempre foi o tempo. Enquanto os dados viviam no SQL Server (transacional/OLTP), a equipe de dados tinha que construir pesados pipelines de ETL (Extract, Transform, Load) usando SSIS, Spark ou Data Factory para copiar esses dados para um Data Warehouse (como o Azure Synapse) e só então gerar relatórios no Power BI. O SQL Server 2025 destrói esse paradigma com a integração nativa ao **Microsoft Fabric**. Agora, seu banco de dados operacional pode "espelhar" suas tabelas diretamente para o OneLake (o lago de dados do Fabric) em tempo real, sem uma única linha de código de ETL.

### 🧠 ENTENDA
A mágica por trás dessa feature se chama *Database Mirroring to Fabric*. Ela opera em três camadas fundamentais:
1. **Replicação Assíncrona Contínua:** O SQL Server 2025 lê o log de transações (transaction log) em tempo real e envia os deltas (mudanças) para o Fabric de forma totalmente transparente, sem impactar a performance da sua aplicação principal.
2. **Formato Aberto (Delta Parquet):** Os dados que chegam ao Fabric não ficam presos em um formato proprietário. Eles são convertidos automaticamente para o formato Delta Lake (Parquet), o padrão de fato da indústria de dados.
3. **Zero Latência para Análise:** Assim que os dados chegam ao OneLake, eles estão instantaneamente disponíveis para os motores do Fabric (SQL Analytics Endpoint, Spark, Data Engineering) e, mais importante, para o **Power BI** em modo DirectLake, permitindo que executivos vejam vendas acontecendo no segundo exato em que são gravadas no SQL Server.

### ⚡ EXECUTE SEU CÓDIGO
A configuração inicial do link entre o SQL Server 2025 e o Fabric envolve o portal e o T-SQL. Abaixo, demonstramos os comandos T-SQL que o DBA executa no SQL Server 2025 para estabelecer e gerenciar esse espelhamento mágico.

```sql
-- 1. CRIAR UMA CREDENCIAL SEGURA PARA O FABRIC
-- O SQL Server precisa de autenticação para escrever no seu Workspace do Fabric
-- (Normalmente usa uma Managed Identity ou Service Principal do Entra ID)
CREATE DATABASE SCOPED CREDENTIAL [Fabric_Mirroring_Cred]
WITH IDENTITY = 'Managed Identity';
GO

-- 2. CRIAR O LINK DE ESPELHAMENTO (A ponte direta para o OneLake)
-- Você aponta o SQL Server para a URL do seu Workspace no Fabric
CREATE EXTERNAL DATA SOURCE [Polydev_Fabric_Lakehouse]
WITH (
    TYPE = FABRIC,
    LOCATION = N'https://onelake.dfs.fabric.microsoft.com/seu-workspace/polydev-lakehouse.Lakehouse',
    CREDENTIAL = [Fabric_Mirroring_Cred]
);
GO

-- 3. PUBLICAR A TABELA NO FABRIC (O fim do ETL)
-- Basta especificar qual tabela do seu banco transacional será espelhada para o OneLake
CREATE FABRIC MIRROR TABLE Vendas_Diarias
TO EXTERNAL DATA SOURCE [Polydev_Fabric_Lakehouse];
GO

-- 4. MONITORAR A SAÚDE DO ESPELHAMENTO
-- O DBA pode acompanhar se a replicação está em dia usando DMVs nativas
SELECT 
    object_name(object_id) AS TabelaLocal,
    mirror_state_desc AS StatusEspelhamento,
    lag_time_seconds AS AtrasoEmSegundos,
    last_sync_time AS UltimaSincronizacao
FROM sys.dm_db_fabric_mirror_state;
-- Se o AtrasoEmSegundos estiver próximo de 0, seu Power BI está em tempo real!

-- NOTA: A partir deste momento, qualquer INSERT/UPDATE/DELETE na tabela 'Vendas_Diarias'
-- aqui no SQL Server, viaja automaticamente para o lago de dados do Fabric. 
-- O Analista de Dados já pode conectar o Power BI direto no OneLake. Fim do ETL noturno!