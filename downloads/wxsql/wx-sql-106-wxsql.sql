SPCAT 42 - Understanding SQL Server Index Fragmentation

Introdução

Fragmentação ocorre quando as páginas de um índice deixam de seguir a organização ideal originalmente criada pelo SQL Server.

Esse fenômeno é resultado natural das operações de INSERT, UPDATE e DELETE.

Existem dois tipos principais:

Fragmentação Externa

As páginas deixam de estar fisicamente próximas.

Consequências:

* Mais leituras
* Mais I/O
* Menor eficiência em scans

Fragmentação Interna

As páginas possuem espaços vazios excessivos.

Consequências:

* Índices maiores
* Mais memória consumida
* Mais páginas para percorrer

Fragmentação não significa necessariamente problema.

Um índice pequeno pode apresentar alta fragmentação sem qualquer impacto perceptível.

Conclusão

O percentual de fragmentação deve sempre ser analisado em conjunto com o tamanho e a utilização do índice.
