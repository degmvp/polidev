/*========================================================
SQLBIT15
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
SWAP TWO VARIABLES WITHOUT USING A THIRD VARIABLE
BITWISE XOR
--------------------------------------------------------*/

declare @x int = 3;
declare @y int = 7;

select @x as x, @y as y;  -- x = 3, y = 7

set @x = @x ^ @y;         -- x = 3 XOR 7 = 4
select @x as x_after_first_xor;

set @y = @y ^ @x;         -- y = 7 XOR 4 = 3
select @y as y_after_second_xor;

set @x = @x ^ @y;         -- x = 4 XOR 3 = 7
select @x as x, @y as y;  -- x = 7, y = 3
