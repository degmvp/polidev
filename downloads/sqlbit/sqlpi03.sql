03 - Localizando as Páginas de uma Tabela

Antes de abrir uma página precisamos descobrir onde ela está.

Código:

DBCC IND('tempdb','Clientes',-1);
GO

Resultado:

PagePID
123
124
125