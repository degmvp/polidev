# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL08AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Performance (Optimized Locking, IQP e Columnstore)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
Quando falamos de performance no SQL Server 2025, não estamos falando apenas de consultas rodando "alguns milissegundos mais rápido". Estamos falando de uma mudança arquitetural profunda na forma como o banco gerencia a concorrência. A estrela desta versão é o **Optimized Locking**, uma feature que elimina décadas de dor de cabeça com bloqueios (blocks) e deadlocks, permitindo que sistemas de alta exigência escalem verticalmente de forma inédita, aliado ao amadurecimento do Query Store e do processamento inteligente de consultas.

### 🧠 ENTENDA
O pacote de performance do SQL Server 2025 é dividido em quatro pilares fundamentais:
1. **Optimized Locking:** Revoluciona o comportamento padrão do `READ COMMITTED`. Em vez de usar travas pesadas em chaves e páginas, o SQL Server agora usa o ID da Transação (TID) como um "carimbo" lógico. Leituras não bloqueiam escritas, e escritas não bloqueiam leituras, eliminando a necessidade de usar o perigoso `NOLOCK` ou de habilitar o pesado `RCSI` (Read Committed Snapshot Isolation).
2. **Query Store Aprimorado:** Melhoria drástica na identificação de regressões de plano e introdução de testes A/B nativos para validar o impacto de índices ou hints antes de aplicar em produção.
3. **Intelligent Query Processing (IQP):** O motor de execução se torna ainda mais adaptativo, ajustando dinamicamente o uso de memória (Memory Grant Feedback) e o paralelismo (DOP) durante a própria execução da query.
4. **Columnstore Turbinado:** Melhorias na compressão de metadados e eliminação de gargalos em operações de *Batch Mode*, tornando análises analíticas (HTAP) quase instantâneas.

### ⚡ EXECUTE SEU CÓDIGO
Veja como ativar a feature mais impactante de performance do SQL Server 2025 e como o banco lida com cenários de concorrência extrema sem travar.

```sql
-- 1. HABILITANDO O OPTIMIZED LOCKING (Nível do Banco de Dados)
-- Esta simples linha muda a arquitetura de locks do seu banco inteiro.
ALTER DATABASE VendasDB SET OPTIMIZED_LOCKING = ON;
GO

-- 2. CENÁRIO CLÁSSICO DE CONCORRÊNCIA RESOLVIDO
-- Sessão 1: Um processo longo está atualizando o estoque de um produto popular
BEGIN TRANSACTION;
UPDATE Estoque SET Quantidade = Quantidade - 1 WHERE ProdutoId = 999;
-- NOTA: A transação fica aberta propositalmente (sem COMMIT ainda).

-- Sessão 2 (RODANDO EM PARALELO): Um relatório precisa ler o estoque
-- NO SQL SERVER ANTIGO: Esta query ficaria "travada" esperando a Sessão 1 dar COMMIT.
-- NO SQL SERVER 2025: A query retorna INSTANTANEAMENTE a versão anterior dos dados,
-- sem usar NOLOCK (o que evitaria o travamento mas traria dados sujos/duplicados).
SELECT ProdutoId, Quantidade 
FROM Estoque 
WHERE ProdutoId = 999;
-- Executa sem bloqueio e com garantia de consistência!

-- 3. INTELLIGENT QUERY PROCESSING (Memory Grant Feedback em Ação)
-- O SQL Server 2025 percebe se uma query pediu memória demais ou de menos na execução anterior
-- e ajusta automaticamente na próxima vez, sem precisar de DBA intervindo.
SELECT 
    ClienteId, 
    SUM(ValorTotal) AS GastoTotal
FROM VendasHistorico
WHERE DataVenda >= '2024-01-01'
GROUP BY ClienteId
ORDER BY GastoTotal DESC;
-- O plano de execução dessa query será adaptado dinamicamente pelo IQP.

-- 4. QUERY STORE: FORÇANDO UM PLANO OTIMIZADO MANUALMENTE (Se necessário)
-- Se o IQP escolher um plano ruim, o DBA pode forçar o anterior facilmente
EXEC sys.sp_query_store_force_plan @query_id = 45, @plan_id = 37;