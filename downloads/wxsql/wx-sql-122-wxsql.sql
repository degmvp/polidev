/*========================================================
SQLBIT02
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
BOOLEAN EXPRESSION
1 - ABS(SIGN(mes - N)) returns:
1 when mes = N
0 when mes <> N
--------------------------------------------------------*/

select
    nome,
    mes,
    valor,
    (1 - abs(sign(mes - 3))) as mes_03_verdadeiro
from dbo.tbval
order by nome, mes;

/*--------------------------------------------------------
FINALIZING MONTH 3
--------------------------------------------------------*/

select
    nome,
    sum(valor * (1 - abs(sign(mes - 3)))) as finalizando_mes_3
from dbo.tbval
group by nome;

/*--------------------------------------------------------
BOOLEAN PIVOT - MONTHS
--------------------------------------------------------*/

select
    nome,
    sum(valor * (1 - abs(sign(mes - 1))))  as jan,
    sum(valor * (1 - abs(sign(mes - 2))))  as fev,
    sum(valor * (1 - abs(sign(mes - 3))))  as mar,
    sum(valor * (1 - abs(sign(mes - 4))))  as abr,
    sum(valor * (1 - abs(sign(mes - 5))))  as mai,
    sum(valor * (1 - abs(sign(mes - 6))))  as jun,
    sum(valor * (1 - abs(sign(mes - 7))))  as jul,
    sum(valor * (1 - abs(sign(mes - 8))))  as ago,
    sum(valor * (1 - abs(sign(mes - 9))))  as [set],
    sum(valor * (1 - abs(sign(mes - 10)))) as out,
    sum(valor * (1 - abs(sign(mes - 11)))) as nov,
    sum(valor * (1 - abs(sign(mes - 12)))) as dez
from dbo.tbval
group by nome;
