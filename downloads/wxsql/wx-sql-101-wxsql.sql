6. Estatísticas (Statistics)
São objetos que armazenam histogramas e informações de distribuição dos dados em uma coluna. O Otimizador de Consultas lê as estatísticas para decidir se fará um SEEK ou SCAN. Se as estatísticas estiverem desatualizadas, o SQL Server pode escolher um plano de execução péssimo.
O SQL Server atualiza automaticamente por padrão, mas em tabelas muito grandes pode ser necessário forçar.

-- Ver as estatísticas de uma coluna/tabela
DBCC SHOW_STATISTICS('Clientes', 'IX_Cliente_Email');

-- Ver as estatísticas de uma coluna/tabela
DBCC SHOW_STATISTICS('Clientes', 'IX_Cliente_Email');

-- Atualizar todas as estatísticas de uma tabela manualmente
UPDATE STATISTICS Clientes;