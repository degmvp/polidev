/*========================================================
SQLBIT03
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BOOLEAN EXPRESSION
========================================================*/

set nocount on;

/*--------------------------------------------------------
CREATE EXAMS TABLE
--------------------------------------------------------*/

if object_id('dbo.exams', 'U') is not null
    drop table dbo.exams;
go

create table dbo.exams (
    pkey  int identity(1,1) not null primary key,
    name  varchar(15)      not null,
    exam  int              not null,
    score int              not null
);
go

insert into dbo.exams (name, exam, score) values
('Deg',  1, 75),
('Deg',  2, 77),
('Deg',  3, 78),
('Deg',  4, 80),
('mary', 1, 90),
('mary', 2, 97),
('mary', 3, 98),
('mary', 4, 99);

select *
from dbo.exams
order by name, exam;

/*--------------------------------------------------------
BOOLEAN PIVOT - EXAMS
--------------------------------------------------------*/

select
    name,
    sum(score * (1 - abs(sign(exam - 1)))) as exam1,
    sum(score * (1 - abs(sign(exam - 2)))) as exam2,
    sum(score * (1 - abs(sign(exam - 3)))) as exam3,
    sum(score * (1 - abs(sign(exam - 4)))) as exam4
from dbo.exams
group by name;
