/*========================================================
SQLBIT11
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
EXPAND BITMASK INTO ROWS

Prerequisite: run SQLBIT10 first.
--------------------------------------------------------*/

select
    m.name,
    o.value
from dbo.Member as m
cross join dbo.opportunitiesLookup as o
where (m.contact_preferences & o.bitwise) <> 0
order by
    m.name,
    o.value;
