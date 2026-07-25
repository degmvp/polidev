# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL06AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** JSON e APIs (RegEx, REST e JSON Otimizado)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O SQL Server 2025 definitive abandona a rigidez estrutural do passado para se tornar um backend completo para aplicações modernas. Se antes você precisava de uma API em Node.js ou C# apenas para formatar um JSON ou validar um e-mail com expressões regulares, agora o próprio banco de dados assume esse papel. Com a chegada do tão esperado **RegEx Nativo**, a consolidação do suporte a **JSON de Alta Performance** e as chamadas **REST**, o SQL Server se posiciona como um banco de dados unificado (Relacional + Documental + API).

### 🧠 ENTENDA
As melhorias neste módulo resolvem décadas de dor de cabeça dos desenvolvedores:
1. **RegEx Nativo:** Pela primeira vez na história do produto, o SQL Server suporta Expressões Regulares nativas no motor (sem precisar habilitar CLR - Common Language Runtime). Funções como `REGEXP_LIKE`, `REGEXP_REPLACE` e `REGEXP_COUNT` permitem validar e manipular strings complexas (CPFs, e-mails, extração de padrões) com extrema velocidade.
2. **JSON Turbinado:** As funções `OPENJSON` e `JSON_VALUE` foram reescritas internamente. O parser agora consome menos CPU e memória, permitindo que o SQL Server 2025 sirva como um banco NoSQL de verdade para aplicações que consomem APIs.
3. **Integração REST:** A combinação de receber dados via REST (visto no SQL03AI) e devolvê-los em JSON nativo permite criar microserviços diretos no banco de dados, reduzindo drasticamente a latência de rede entre a camada de aplicação e os dados.

### ⚡ EXECUTE SEU CÓDIGO
Veja como a combinação de RegEx e JSON transforma operações que antes exigiam muito código externo em tarefas simples dentro do T-SQL.

```sql
-- 1. REGEX NATIVO: Validação e limpeza de dados (Sem usar CLR!)
-- Suponha uma tabela com dados sujos importados de um sistema legado
DECLARE @TabelaLegada TABLE (Id INT, DadoSujo VARCHAR(100));
INSERT INTO @TabelaLegada VALUES 
(1, 'João Silva - (11) 99999-1234'),
(2, 'Maria-invalida'),
(3, 'Jose Souza - (21) 98765-4321');

-- Validando quem tem um padrão de telefone correto usando REGEXP_LIKE
SELECT Id, DadoSujo
FROM @TabelaLegada
WHERE REGEXP_LIKE(DadoSujo, '\(\d{2}\)\s\d{4,5}-\d{4}');

-- Limpando os dados e extraindo apenas os números com REGEXP_REPLACE
SELECT 
    Id, 
    DadoSujo,
    REGEXP_REPLACE(DadoSujo, '[^0-9]', '') AS TelefoneNumericoApenas
FROM @TabelaLegada
WHERE REGEXP_LIKE(DadoSujo, '\(\d{2}\)');

-- 2. JSON OTIMIZADO: Transformando dados relacionais em resposta de API instantaneamente
-- O clause FOR JSON PATH agora é mais rápido para serializar grandes volumes
SELECT 
    ClienteId AS Id,
    Nome AS NomeCompleto,
    Email AS Contato
FROM Clientes
WHERE Ativo = 1
FOR JSON PATH; 
-- Saída: [{"Id":1,"NomeCompleto":"João","Contato":"joao@x.com"}, ...]

-- 3. MANIPULAÇÃO AVANÇADA: Atualizando um nó específico dentro de um JSON
DECLARE @PedidoJSON NVARCHAR(MAX) = N'{
    "numero": 1020,
    "status": "PROCESSANDO",
    "itens": [{"prod": "Notebook", "qtd": 1}]
}';

-- Usando JSON_MODIFY para alterar apenas o status sem reescrever o documento inteiro
SET @PedidoJSON = JSON_MODIFY(@PedidoJSON, '$.status', 'PAGO');

-- Extraindo dados internos com OPENJSON de forma ultra otimizada
SELECT 
    Produto, 
    Quantidade 
FROM OPENJSON(@PedidoJSON, '$.itens') 
WITH (
    Produto VARCHAR(50) '$.prod',
    Quantidade INT '$.qtd'
);