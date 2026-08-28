# /*

# POLYDEV BLACK BELT

Arquivo....: bbpart03.sql
Título.....: Partition Scheme and Filegroups
Categoria..: bbpart

Objetivo:
Demonstrar como uma Partition Scheme conecta a Partition Function aos
filegroups físicos do SQL Server.

===============================================================================
*/

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'POLYDEV BLACK BELT';
PRINT 'Partition Scheme and Filegroups';
PRINT '=============================================================';
GO

# /*

# O QUE É UMA PARTITION SCHEME

A Partition Function define as fronteiras.

A Partition Scheme define onde cada partição será armazenada.

Em produção, cada filegroup pode apontar para arquivos diferentes,
discos diferentes ou camadas diferentes de armazenamento.

Exemplo conceitual:

PF_Telemetria_Mensal
|
v
PS_Telemetria_Mensal
|
+--> FG_TELEMETRIA_OLD
+--> FG_TELEMETRIA_2026_01
+--> FG_TELEMETRIA_2026_02
+--> FG_TELEMETRIA_2026_03
+--> FG_TELEMETRIA_CURRENT

===============================================================================
*/

PRINT 'Preparando filegroups para particionamento.';
GO

# /*

# FILEGROUPS

Este script cria filegroups lógicos.

Observação:
Em ambiente real, após criar os filegroups, o DBA deve adicionar arquivos
físicos com ALTER DATABASE ADD FILE.

Aqui mantemos o exemplo didático e seguro para estudo.

===============================================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_TELEMETRIA_OLD')
BEGIN
ALTER DATABASE CURRENT ADD FILEGROUP FG_TELEMETRIA_OLD;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_TELEMETRIA_2026_01')
BEGIN
ALTER DATABASE CURRENT ADD FILEGROUP FG_TELEMETRIA_2026_01;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_TELEMETRIA_2026_02')
BEGIN
ALTER DATABASE CURRENT ADD FILEGROUP FG_TELEMETRIA_2026_02;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_TELEMETRIA_2026_03')
BEGIN
ALTER DATABASE CURRENT ADD FILEGROUP FG_TELEMETRIA_2026_03;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_TELEMETRIA_CURRENT')
BEGIN
ALTER DATABASE CURRENT ADD FILEGROUP FG_TELEMETRIA_CURRENT;
END
GO

# /*

# IMPORTANTE

Para que um filegroup receba dados, ele precisa possuir pelo menos um arquivo.

Exemplo de produção:

ALTER DATABASE SeuBanco
ADD FILE
(
NAME = N'Telemetria_2026_01',
FILENAME = N'D:\SQLDATA\Telemetria_2026_01.ndf',
SIZE = 1024MB,
FILEGROWTH = 512MB
)
TO FILEGROUP FG_TELEMETRIA_2026_01;

Neste material, deixamos os comandos comentados para evitar dependência
de caminhos físicos no computador do aluno.

===============================================================================
*/

/*
ALTER DATABASE CURRENT
ADD FILE
(
NAME = N'Telemetria_2026_01',
FILENAME = N'D:\SQLDATA\Telemetria_2026_01.ndf',
SIZE = 1024MB,
FILEGROWTH = 512MB
)
TO FILEGROUP FG_TELEMETRIA_2026_01;
GO
*/

# /*

# VALIDAÇÃO DOS FILEGROUPS

*/

SELECT
name,
type_desc,
is_default,
is_read_only
FROM sys.filegroups
WHERE name LIKE 'FG_TELEMETRIA%';
GO

# /*

# PARTITION SCHEME

A Partition Scheme abaixo utiliza a Partition Function criada no bbpart02.sql.

Para a Partition Function:

PF_Telemetria_Mensal

Com fronteiras:

2026-01-01
2026-02-01
2026-03-01
2026-04-01

Temos 5 partições.

Por isso, informamos 5 destinos.

===============================================================================
*/

IF NOT EXISTS
(
SELECT 1
FROM sys.partition_schemes
WHERE name = 'PS_Telemetria_Mensal'
)
BEGIN
CREATE PARTITION SCHEME PS_Telemetria_Mensal
AS PARTITION PF_Telemetria_Mensal
TO
(
FG_TELEMETRIA_OLD,
FG_TELEMETRIA_2026_01,
FG_TELEMETRIA_2026_02,
FG_TELEMETRIA_2026_03,
FG_TELEMETRIA_CURRENT
);
END
GO

# /*

# VALIDAÇÃO DA PARTITION SCHEME

*/

SELECT
ps.name AS PartitionScheme,
pf.name AS PartitionFunction,
pf.fanout AS TotalParticoes
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf
ON ps.function_id = pf.function_id
WHERE ps.name = 'PS_Telemetria_Mensal';
GO

# /*

# MAPEAMENTO DAS PARTIÇÕES

*/

SELECT
ps.name AS PartitionScheme,
dds.destination_id AS PartitionNumber,
fg.name AS FilegroupName
FROM sys.partition_schemes ps
INNER JOIN sys.destination_data_spaces dds
ON ps.data_space_id = dds.partition_scheme_id
INNER JOIN sys.filegroups fg
ON dds.data_space_id = fg.data_space_id
WHERE ps.name = 'PS_Telemetria_Mensal'
ORDER BY dds.destination_id;
GO

# /*

# CONCEITO BLACK BELT

A Partition Function responde:

"Qual faixa temporal pertence a qual partição?"

A Partition Scheme responde:

"Onde cada partição será armazenada?"

Essa separação permite:

1. Escalar armazenamento
2. Isolar dados quentes e frios
3. Melhorar manutenção
4. Preparar Sliding Window
5. Separar histórico por filegroup

===============================================================================
*/

PRINT 'Partition Scheme criada e validada.';
PRINT 'Próximo programa: bbpart04.sql';
GO
