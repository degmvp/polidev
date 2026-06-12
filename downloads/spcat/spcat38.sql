8. Reorganize (Reorganização)
Reordena fisicamente apenas as páginas de folha do índice de forma incremental. É uma operação mais leve, feita online (não bloqueia a tabela), mas só resolve a fragmentação externa e é ineficaz se a fragmentação for gigantesca.
Deve ser usado quando a fragmentação está entre 10% e 30%.


ALTER INDEX IX_Cliente_Email ON Clientes REORGANIZE;

Dica de Ouro: Nunca faça Reorganize em um índice com fragmentação menor que 10%, 
pois o custo de CPU e I/O será maior do que o benefício.