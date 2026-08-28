/*========================================================
SQLBIT20
T-SQL FOR SMARTIES
DEEP DIVE FROM BIT TO TOP
BITWISE OPERATIONS
========================================================*/

set nocount on;

/*--------------------------------------------------------
BITWISE AND PERMISSION CHECKS
--------------------------------------------------------*/

/*
Bitwise AND example:

        x: 10001101
        y: 01010111
   x & y: 00000101

Bitwise OR example:

        x: 10001101
        y: 01010111
   x | y: 11011111
*/

select
    ProfileName = 'Simple Delete User',
    PermissionValue = 63,
    PermissionBit = 4,
    HasPermission = case when (63 & 4) = 4 then 'YES' else 'NO' end;

select
    ProfileName = 'Super User',
    PermissionValue = 27,
    PermissionBit = 4,
    HasPermission = case when (27 & 4) = 4 then 'YES' else 'NO' end;

select
    ProfileName = 'User',
    PermissionValue = 2,
    PermissionBit = 4,
    HasPermission = case when (2 & 4) = 4 then 'YES' else 'NO' end;

select
    ProfileName = 'Group Admin',
    PermissionValue = 56,
    PermissionBit = 4,
    HasPermission = case when (56 & 4) = 4 then 'YES' else 'NO' end;
