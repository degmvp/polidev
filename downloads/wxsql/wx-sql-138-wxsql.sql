/*========================================================
SQLBIT18
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
CLASSIFY CALLS AS LOCAL OR DDD-INTER USING BOOLEAN MATH
--------------------------------------------------------*/

if object_id('dbo.calls', 'U') is not null
    drop table dbo.calls;
go

create table dbo.calls (
    nome     varchar(10)  not null,
    fro_area tinyint      not null,
    to_area  tinyint      not null,
    cost     decimal(8,2) not null
);
go

insert into dbo.calls (nome, fro_area, to_area, cost) values
('Deg', 83, 83, 10.35),
('Deg', 83, 83, 15.35),
('Deg', 83, 21,  2.35),
('Deg', 83, 21,  5.35),
('Law', 83, 83,  1.35),
('Law', 83, 83,  5.35);

/*
When fro_area = to_area, the boolean expression returns position 1 and length 5: local.
When fro_area <> to_area, NULLIF avoids division by zero and ISNULL selects position 6 and length 9: DDD-Inter.
*/

select
    nome,
    call_type = substring(
                    'localDDD-Inter',
                    isnull(1 / nullif((1 - abs(sign(fro_area - to_area))), 0), 6),
                    isnull(5 / nullif((1 - abs(sign(fro_area - to_area))), 0), 9)
                ),
    total_cost = sum(cost)
from dbo.calls
group by
    nome,
    substring(
        'localDDD-Inter',
        isnull(1 / nullif((1 - abs(sign(fro_area - to_area))), 0), 6),
        isnull(5 / nullif((1 - abs(sign(fro_area - to_area))), 0), 9)
    );
