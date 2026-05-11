/*========================================================
SQLBIT12
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
SEARCH BITMASK ASSOCIATIONS

Prerequisite: run SQLBIT10 first.
--------------------------------------------------------*/

with assoc as (
    select
        m.name,
        o.value
    from dbo.Member as m
    cross join dbo.opportunitiesLookup as o
    where (m.contact_preferences & o.bitwise) <> 0
)
select name
from assoc
where value = 'Create Table'
order by name;

with assoc as (
    select
        m.name,
        o.value
    from dbo.Member as m
    cross join dbo.opportunitiesLookup as o
    where (m.contact_preferences & o.bitwise) <> 0
)
select name
from assoc
where value = 'Alter Procedure'
order by name;
