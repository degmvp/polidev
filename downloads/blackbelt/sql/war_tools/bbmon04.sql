bbmon04.sql
SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    t.user_objects_alloc_page_count * 8 AS user_objects_kb,
    t.internal_objects_alloc_page_count * 8 AS internal_objects_kb,
    t.user_objects_dealloc_page_count * 8 AS user_dealloc_kb,
    t.internal_objects_dealloc_page_count * 8 AS internal_dealloc_kb
FROM sys.dm_db_session_space_usage t
INNER JOIN sys.dm_exec_sessions s
    ON s.session_id = t.session_id
WHERE s.is_user_process = 1
ORDER BY
    (t.user_objects_alloc_page_count + t.internal_objects_alloc_page_count) DESC;