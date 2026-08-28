/*========================================================
SQLBIT17
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
CLASSIFICATION TEST TABLE
--------------------------------------------------------*/

if object_id('dbo.uxt_class02', 'U') is not null
    drop table dbo.uxt_class02;
go

create table dbo.uxt_class02 (
    obj_pk    int     not null,
    obj_code  tinyint not null,
    obj_value char(1) not null
);
go

declare @x int = 0;

while @x < 10
begin
    insert into dbo.uxt_class02 (obj_pk, obj_code, obj_value) values
    (111, 1, 'A'),
    (111, 2, 'B'),
    (111, 3, 'C'),
    (111, 4, 'D'),
    (112, 1, 'E'),
    (112, 2, 'B'),
    (112, 3, 'F'),
    (112, 4, 'D');

    set @x = @x + 1;
end;

select *
from dbo.uxt_class02
order by obj_pk, obj_code;
