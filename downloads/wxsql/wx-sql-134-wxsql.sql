/*========================================================
SQLBIT14
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
LIST ALL BINARY MAPPING OCCURRENCES AS A PIVOT

Prerequisite: run SQLBIT10 first.
--------------------------------------------------------*/

select
    name,
    [Administrador DBA],
    [Query tables],
    [Insert tables],
    [Delete Procedures],
    [Update Table],
    [Create Views],
    [Alter Procedure],
    [Create Table]
from (
    select
        m.name,
        o.value,
        1 as num
    from dbo.Member as m
    cross join dbo.opportunitiesLookup as o
    where (m.contact_preferences & o.bitwise) <> 0
) as D
pivot (
    count(num)
    for value in (
        [Administrador DBA],
        [Query tables],
        [Insert tables],
        [Delete Procedures],
        [Update Table],
        [Create Views],
        [Alter Procedure],
        [Create Table]
    )
) as P
order by name;
