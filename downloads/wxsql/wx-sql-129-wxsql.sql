/*========================================================
SQLBIT09
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
DECOMPOSE INTEGER VALUES INTO BINARY/HEXA POSITIONS

Prerequisite: run SQLBIT07 first to create dbo.Bits.
--------------------------------------------------------*/

declare @v bigint;

set @v = 57;

select
    hexa_label,
    @v & hexa_pos as dec_pos,
    idbin         as [Bit Pos]
from dbo.Bits
where (@v & hexa_pos) = hexa_pos
order by idbin;

set @v = 195;

select
    hexa_label,
    @v & hexa_pos as dec_pos,
    idbin         as [Bit Pos]
from dbo.Bits
where (@v & hexa_pos) = hexa_pos
order by idbin;
