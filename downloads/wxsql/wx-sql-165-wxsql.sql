05 - Registros de Tamanho Fixo

Colunas:

CHAR
INT
DATE
BIGINT

possuem tamanho previsível.

Exemplo:

CREATE TABLE Produto
(
    Id INT,
    Codigo CHAR(10)
);

Características:

Atualização simples
Menor processamento
Endereçamento direto

O SQL Server grava o valor sempre na mesma posição física.