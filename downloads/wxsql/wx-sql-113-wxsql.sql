# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL03AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Integração com modelos de IA (Endpoinst REST Nativos)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
Historicamente, se você quisesse que o seu banco de dados SQL Server "conversasse" com uma Inteligência Artificial (como o ChatGPT), você era obrigado a criar uma aplicação intermediária (em C#, Python, etc.) para buscar os dados no banco, enviar para a API da OpenAI, receber a resposta e devolver para o banco. O SQL Server 2025 elimina essa ponte. Agora, o próprio motor do banco de dados consegue fazer chamadas HTTP/REST diretamente para modelos de IA, seja na nuvem (Azure OpenAI, OpenAI) ou localmente (Ollama, LM Studio).

### 🧠 ENTENDA
O segredo dessa funcionalidade é a nova stored procedure de sistema: `sp_invoke_external_rest_endpoint`. Com ela, você monta um payload JSON contendo o seu prompt, define as credenciais de segurança (sem expor senhas no código) e o T-SQL faz a requisição web de forma assíncrona e nativa. O retorno (também em JSON) pode ser imediatamente parseado e salvo em uma tabela ou retornado para o usuário. Isso permite criar "Agentes de IA" diretamente em procedures, triggers ou jobs do SQL Agent, mantendo a lógica 100% dentro do ecossistema do banco.

### ⚡ EXECUTE SEU CÓDIGO
Abaixo demonstramos como configurar uma credencial segura e chamar o Azure OpenAI diretamente do T-SQL para classificar um texto, sem precisar de nenhuma linha de código em outra linguagem.

```sql
-- 1. CRIANDO UMA CREDENCIAL SEGURA (Faça isso apenas uma vez)
-- Isso armazena a chave da API de forma criptografada pelo SQL Server
CREATE CREDENTIAL [AzureOpenAI_Cred]
WITH IDENTITY = 'User', SECRET = 'sua-chave-api-aqui-do-azure';
GO

-- 2. PREPARANDO A CHAMADA NATIVA
DECLARE @Url NVARCHAR(4000) = N'https://seu-recurso.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01';
DECLARE @Payload NVARCHAR(MAX) = N'{
    "messages": [
        {"role": "system", "content": "Você é um assistente que classifica o sentimento de textos."},
        {"role": "user", "content": "Classifique o sentimento deste texto: O servidor caiu e perdemos todos os dados de produção!"}
    ]
}';
DECLARE @RespostaJSON NVARCHAR(MAX);
DECLARE @CodigoRetorno INT;

-- 3. INVOCANDO A IA DIRETAMENTE DO T-SQL
EXEC @CodigoRetorno = sp_invoke_external_rest_endpoint 
    @url = @Url,
    @method = 'POST',
    @credential = [AzureOpenAI_Cred],
    @payload = @Payload,
    @response = @RespostaJSON OUTPUT;

-- 4. TRATANDO O RETORNO DA IA
-- Extraímos exatamente a resposta gerada pelo LLM dentro do JSON de retorno
SELECT 
    @CodigoRetorno AS StatusCodeHTTP,
    JSON_VALUE(@RespostaJSON, '$.choices[0].message.content') AS RespostaDaIA;
GO