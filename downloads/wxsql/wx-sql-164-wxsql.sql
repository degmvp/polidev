Esses identificadores serão usados no DBCC PAGE.

04 - Abrindo uma Página Real

Agora visualizamos a página.

Código:

DBCC TRACEON(3604);
GO

DBCC PAGE('tempdb',1,123,3);
GO

Nível 3 exibe:

Header
Registros
Offsets
Slot Array