01 - O Que é uma Página de Dados

O SQL Server armazena informações em páginas de 8 KB.

Cada página contém:

Cabeçalho
Registros
Espaço Livre
Slot Array

Inserir Imagem 1

(estrutura interna da página)

Código:

SELECT 8192 AS BytesPorPagina;