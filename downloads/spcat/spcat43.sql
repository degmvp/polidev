SPCAT 43 - Page Splits: The Hidden Enemy of SQL Server Performance

Introdução

Page Split é um dos principais responsáveis pela fragmentação em SQL Server.

Quando uma página está cheia e um novo registro precisa ser inserido no meio da estrutura ordenada do índice, o SQL Server divide a página em duas.

Esse processo gera:

* Escritas adicionais
* Movimentação de dados
* Fragmentação
* Crescimento do índice

Principais causas:

* Chaves aleatórias
* GUIDs não sequenciais
* Fill Factor inadequado
* Atualizações que aumentam o tamanho da linha

Como identificar

DMVs operacionais permitem identificar índices que sofrem grande quantidade de page splits.

A análise contínua desses eventos ajuda a detectar problemas antes que afetem os usuários.

Conclusão

Muitos problemas atribuídos à fragmentação são, na realidade, sintomas de page splits excessivos.
