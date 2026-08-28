bbmon05.sql
SELECT
    physical_memory_kb / 1024 AS physical_memory_mb,
    available_physical_memory_kb / 1024 AS available_memory_mb,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;

SELECT
    total_physical_memory_kb / 1024 AS sql_total_physical_mb,
    available_physical_memory_kb / 1024 AS sql_available_physical_mb,
    total_page_file_kb / 1024 AS total_page_file_mb,
    available_page_file_kb / 1024 AS available_page_file_mb
FROM sys.dm_os_sys_memory;