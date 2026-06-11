2 - Estrutura do Cabeçalho da Página

O cabeçalho possui informações administrativas.

Entre elas:

ID da página
Tipo
Espaço livre
Quantidade de registros

Visualização:

DBCC TRACEON(3604);
GO

DBCC PAGE('tempdb',1,123,0);
GO

Campos importantes:

m_pageId
m_type
m_slotCnt
m_freeCnt