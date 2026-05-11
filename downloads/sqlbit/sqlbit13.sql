/*========================================================
SQLBIT13
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
CONCATENATE BITMASK ASSOCIATIONS PER MEMBER

Prerequisite: run SQLBIT10 first.
--------------------------------------------------------*/

select
    n.name as [Name],
    ltrim(stuff((
        select ', ' + o.value as [text()]
        from dbo.Member as m
        cross join dbo.opportunitiesLookup as o
        where (m.contact_preferences & o.bitwise) <> 0
          and m.name = n.name
        order by o.value
        for xml path(''), type
    ).value('.', 'varchar(max)'), 1, 1, '')) as Preferences
from dbo.Member as n
order by n.name;
