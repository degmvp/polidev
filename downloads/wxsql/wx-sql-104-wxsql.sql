10. Execution Plans (Planos de Execução)
É o "mapa" gerado pelo SQL Server mostrando exatamente como ele vai buscar os dados. É a ferramenta definitiva para saber se seus índices estão funcionando ou não.
No SQL Server Management Studio (SSMS), você pode habilitá-lo de duas formas:

Clicando no ícone "Include Actual Execution Plan" (ou Ctrl + M) antes de rodar o SELECT.
Olhando visualmente o plano gerado:
Se vir um "Table Scan" fino, é ruim (leu a tabela inteira sem índice).
Se vir um "Index Seek", é ótimo.
Se vir uma "Key Lookup" (uma setinha voltando para a tabela clusterizada após um Index Seek NonClustered), significa que o índice nonclustered não tem todas as colunas que o SELECT precisa (solução: adicionar colunas com INCLUDE).
Se vir um ícone verde com uma lupa escrito "Missing Index", o SQL Server está pedindo socorro e sugerindo a criação de um índice ali mesmo.