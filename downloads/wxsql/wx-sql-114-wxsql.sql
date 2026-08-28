# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL04AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Copilot para DBAs (SSMS 21)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O SQL Server Management Studio (SSMS) versão 21 chega com uma revolução para a produtividade diária dos DBAs e Desenvolvedores: a integração nativa do GitHub Copilot. Não estamos falando de um simples "autocompletar de palavras", mas de um assistente de IA contextual que entende a estrutura do seu banco de dados, o seu esquema (schema) e o histórico da sua sessão. O objetivo é remover o atrito entre a ideia mental e a execução no banco, permitindo que profissionais foquem em arquitetura e resolução de problemas, não em sintaxe.

### 🧠 ENTENDA
O Copilot no SSMS 21 atua em três frentes principais:
1. **Geração Contextual:** Ele lê as tabelas, views e procedures do seu banco no Object Explorer. Se você pedir para "criar um select joining clientes e pedidos", ele já sabe os nomes exatos das colunas e as chaves primárias/estrangeiras.
2. **Refatoração e Otimização:** Você pode selecionar uma query problemática (por exemplo, cheia de subconsultas ou cursors) e pedir ao Copilot para reescrevê-la usando melhores práticas ou CTEs.
3. **Assistente Administrativo:** No chat embutido, você pode pedir coisas como "Gere um script para fazer backup de todas as databases user" ou "Quais índices estão fragmentados acima de 30%?" e ele escreve o T-SQL ou PowerShell exato para você.

### ⚡ EXECUTE SEU CÓDIGO
Como o Copilot é uma ferramenta de interface (UI) do SSMS, o "código" abaixo demonstra a **Interação Humano-Máquina**. Veja como um DBA transforma uma tarefa complexa em segundos usando prompts no SSMS 21.

```sql
-- CENÁRIO: O DBA precisa criar um script de manutenção, mas não lembra a sintaxe exata do DBCC ou como filtrar por fragmentação.
-- Ele abre o painel do Copilot no SSMS 21 e digita o seguinte PROMPT:

/*
PROMPT PARA O COPILOT:
"Escreva uma query T-SQL que liste todos os índices da base atual 
onde o índice não é um Heap, tem mais de 1000 páginas, 
e a fragmentação média está acima de 15%. Inclua comandos de ALTER INDEX para reorganizar (se <= 30%) 
ou reconstruir (se > 30%) online."
*/

-- RESULTADO GERADO PELO COPILOT EM SEGUNDOS (Pronto para o DBA executar):
SELECT 
    OBJECT_NAME(ind.object_id) AS Tabela,
    ind.name AS Indice,
    stat.avg_fragmentation_in_percent,
    stat.page_count,
    CASE 
        WHEN stat.avg_fragmentation_in_percent > 30.0 
            THEN 'ALTER INDEX [' + ind.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + OBJECT_NAME(ind.object_id) + '] REBUILD WITH (ONLINE = ON);'
        WHEN stat.avg_fragmentation_in_percent > 15.0 
            THEN 'ALTER INDEX [' + ind.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + OBJECT_NAME(ind.object_id) + '] REORGANIZE;'
        ELSE 'Nenhuma ação necessária.'
    END AS AcaoGerada
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS stat
INNER JOIN sys.indexes AS ind ON stat.object_id = ind.object_id AND stat.index_id = ind.index_id
INNER JOIN sys.tables AS t ON ind.object_id = t.object_id
WHERE stat.page_count > 1000 
  AND ind.name IS NOT NULL
  AND stat.avg_fragmentation_in_percent > 15.0
ORDER BY stat.avg_fragmentation_in_percent DESC;