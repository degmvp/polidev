CREATE OR ALTER FUNCTION dbo.bb_fn05_bitwise_has_flag
(
    @valor INT,
    @flag INT
)
RETURNS BIT
AS
BEGIN
    RETURN CASE 
        WHEN (@valor & @flag) = @flag THEN 1 
        ELSE 0 
    END;
END;
GO