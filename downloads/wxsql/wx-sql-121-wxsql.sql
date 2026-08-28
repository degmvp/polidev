/*========================================================
SQLBIT01
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
CREATE TABLE AND LOAD TEST DATA
--------------------------------------------------------*/

if object_id('dbo.tbval', 'U') is not null
    drop table dbo.tbval;
go

create table dbo.tbval (
    nome  varchar(30)  not null,
    valor decimal(8,2) not null,
    mes   tinyint      not null
);
go

/*--------------------------------------------------------
LOAD TEST DATA - LAW
--------------------------------------------------------*/

declare @x1 tinyint = 1;
declare @sal decimal(8,2) = 8001;

while @x1 < 13
begin
    insert into dbo.tbval (nome, valor, mes)
    values ('Law', @sal, @x1);

    set @x1 = @x1 + 1;
    set @sal = @sal + 1;
end;
go

/*--------------------------------------------------------
LOAD TEST DATA - DEG
--------------------------------------------------------*/

declare @x1 tinyint = 1;
declare @sal decimal(8,2) = 6001;

while @x1 < 13
begin
    insert into dbo.tbval (nome, valor, mes)
    values ('Deg', @sal, @x1);

    set @x1 = @x1 + 1;
    set @sal = @sal + 1;
end;
go

/*--------------------------------------------------------
CHECK DATA
--------------------------------------------------------*/

select nome, valor, mes
from dbo.tbval
order by nome, mes;
