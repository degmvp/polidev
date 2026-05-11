/*========================================================
SQLBIT19
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
SEARCH VALUES IN COLUMNS B OR C DEPENDING ON COLUMN A
--------------------------------------------------------*/

if object_id('dbo.delta', 'U') is not null
    drop table dbo.delta;
go

create table dbo.delta (
    nome char(10) not null,
    A    tinyint  not null,
    B    tinyint  not null,
    C    tinyint  not null
);
go

insert into dbo.delta (nome, A, B, C) values
('DEG', 1, 22, 33),
('LAW', 2, 55, 44),
('DAV', 3, 66, 77),
('DGW', 3, 88, 11);

/*
The expression below selects B when A = N.
Otherwise, it selects C.
*/

select
    nome,
    X = B * (1 - abs(sign(A - 1)))
      + C * abs(sign(A - 1))
from dbo.delta;

select
    nome,
    X = B * (1 - abs(sign(A - 2)))
      + C * abs(sign(A - 2))
from dbo.delta;

select
    nome,
    X = B * (1 - abs(sign(A - 3)))
      + C * abs(sign(A - 3))
from dbo.delta;

/*--------------------------------------------------------
SEPARATED COMPONENTS
--------------------------------------------------------*/

select
    nome,
    X = B * (1 - abs(sign(A - 1)))
from dbo.delta;

select
    nome,
    X = C * abs(sign(A - 1))
from dbo.delta;
