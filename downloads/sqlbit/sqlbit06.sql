/*========================================================
SQLBIT06
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BOOLEAN EXPRESSION
========================================================*/

set nocount on;

/*--------------------------------------------------------
PIVOT TABLE EXAMS
CALCULATE DELTAS + TOTAL INCREASE POINTS + AVERAGE

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
  - sum(score * (1 - abs(sign(exam - 3)))) as delta_3_4,

    (
        sum(score * (1 - abs(sign(exam - 2)))) - sum(score * (1 - abs(sign(exam - 1))))
      + sum(score * (1 - abs(sign(exam - 3)))) - sum(score * (1 - abs(sign(exam - 2))))
      + sum(score * (1 - abs(sign(exam - 4)))) - sum(score * (1 - abs(sign(exam - 3))))
    ) as TotalIncPoints,

    (
        sum(score * (1 - abs(sign(exam - 1))))
      + sum(score * (1 - abs(sign(exam - 2))))
      + sum(score * (1 - abs(sign(exam - 3))))
      + sum(score * (1 - abs(sign(exam - 4))))
    ) / 4.0 as AvgScore
from dbo.exams
group by name;
