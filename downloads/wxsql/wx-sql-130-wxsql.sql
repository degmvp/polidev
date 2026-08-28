/*========================================================
SQLBIT10
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
BITMASK MAPPING
2^64 = 18,446,744,073,709,551,616
--------------------------------------------------------*/

if object_id('dbo.Member', 'U') is not null
    drop table dbo.Member;

go

if object_id('dbo.opportunitiesLookup', 'U') is not null
    drop table dbo.opportunitiesLookup;

go

create table dbo.Member (
    id                  int         not null,
    name                varchar(20) not null,
    contact_preferences int         not null
);

insert into dbo.Member (id, name, contact_preferences) values
(1, 'Bob',   255),
(2, 'John',   84),
(3, 'Cathy',  73),
(4, 'Steve', 170);

create table dbo.opportunitiesLookup (
    bitwise int         not null,
    value   varchar(30) not null
);

insert into dbo.opportunitiesLookup (bitwise, value) values
(1,   'Administrador DBA'),
(2,   'Query tables'),
(4,   'Insert tables'),
(8,   'Delete Procedures'),
(16,  'Update Table'),
(32,  'Create Views'),
(64,  'Alter Procedure'),
(128, 'Create Table');

select * from dbo.Member order by id;
select * from dbo.opportunitiesLookup order by bitwise;
