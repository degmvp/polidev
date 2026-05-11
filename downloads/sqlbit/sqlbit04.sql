/*========================================================
SQLBIT04
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BOOLEAN EXPRESSION
========================================================*/

set nocount on;

/*--------------------------------------------------------
ABS FUNCTION
--------------------------------------------------------*/

select abs(1)  as abs_positive;
select abs(-1) as abs_negative;
select abs(0)  as abs_zero;

/*--------------------------------------------------------
SIGN FUNCTION
--------------------------------------------------------*/

select sign(12)  as sign_positive;
select sign(-12) as sign_negative;
select sign(0)   as sign_zero;

/*--------------------------------------------------------
PIVOT TABLE EXAMS
CALCULATE delta_1_2, delta_2_3, delta_3_4

Prerequisite: run SQLBIT03 first to create dbo.exams.
--------------------------------------------------------*/

select
    name,
    sum(score * (1 - abs(sign(exam - 1)))) as exam1,
    sum(score * (1 - abs(sign(exam - 2)))) as exam2,
    sum(score * (1 - abs(sign(exam - 3)))) as exam3,
    sum(score * (1 - abs(sign(exam - 4)))) as exam4,

    sum(score * (1 - abs(sign(exam - 2))))
  - sum(score * (1 - abs(sign(exam - 1)))) as delta_1_2,

    sum(score * (1 - abs(sign(exam - 3))))
  - sum(score * (1 - abs(sign(exam - 2)))) as delta_2_3,

    sum(score * (1 - abs(sign(exam - 4))))
  - sum(score * (1 - abs(sign(exam - 3)))) as delta_3_4
from dbo.exams
group by name;
