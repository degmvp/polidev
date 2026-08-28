/*========================================================
SQLBIT16
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
CONVERT INTEGER TO BINARY AND BINARY TO INTEGER
--------------------------------------------------------*/

create or alter function dbo.fn_generate_binary_frominteger
(
    @integer bigint
)
returns varchar(64)
as
begin
    declare @binary varchar(64) = '';

    if @integer = 0
        return '0';

    while @integer > 0
    begin
        set @binary = cast((@integer % 2) as varchar(1)) + @binary;
        set @integer = @integer / 2;
    end;

    return @binary;
end;
go

create or alter function dbo.fn_generate_integer_frombinary
(
    @binary varchar(64)
)
returns bigint
as
begin
    if @binary is null or @binary = '' or @binary like '%[^01]%'
        return -1;

    declare @cnt int = 1;
    declare @length int = len(@binary);
    declare @integer bigint = 0;

    while @cnt <= @length
    begin
        set @integer = @integer * 2 + cast(substring(@binary, @cnt, 1) as int);
        set @cnt = @cnt + 1;
    end;

    return @integer;
end;
go

select dbo.fn_generate_binary_frominteger(57) as binary_57;
select dbo.fn_generate_integer_frombinary('111001') as integer_111001;
