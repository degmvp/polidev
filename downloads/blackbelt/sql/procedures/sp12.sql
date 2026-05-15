CREATE OR ALTER PROCEDURE dbo.bb_sp12_criar_auditoria_ddl
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.bb_auditoria_ddl', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.bb_auditoria_ddl
        (
            id INT IDENTITY(1,1) PRIMARY KEY,
            data_evento DATETIME DEFAULT GETDATE(),
            evento NVARCHAR(200),
            usuario NVARCHAR(200),
            comando_xml XML
        );
    END;

    IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'tr_bb_auditoria_ddl')
        DROP TRIGGER tr_bb_auditoria_ddl ON DATABASE;

    EXEC('
        CREATE TRIGGER tr_bb_auditoria_ddl
        ON DATABASE
        FOR DDL_DATABASE_LEVEL_EVENTS
        AS
        BEGIN
            SET NOCOUNT ON;

            INSERT INTO dbo.bb_auditoria_ddl(evento, usuario, comando_xml)
            VALUES
            (
                EVENTDATA().value(''(/EVENT_INSTANCE/EventType)[1]'',''NVARCHAR(200)''),
                SYSTEM_USER,
                EVENTDATA()
            );
        END
    ');

    SELECT 'Auditoria DDL criada com sucesso.' AS mensagem;
END;
GO