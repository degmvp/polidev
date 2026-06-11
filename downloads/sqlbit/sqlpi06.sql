06 - Registros de Tamanho Variável

Colunas:

VARCHAR
NVARCHAR
VARBINARY

podem mudar de tamanho.

Exemplo:

Nome VARCHAR(100)
Descricao VARCHAR(500)

Nesse caso o SQL Server precisa controlar onde cada campo termina.

Para isso utiliza uma tabela de offsets.