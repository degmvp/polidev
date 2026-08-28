# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL02AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** RAG (Retrieval-Augmented Generation)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O RAG (Geração Aumentada por Recuperação) é o padrão arquitetural mais importante da atualidade para IA Corporativa. Ele resolve o maior problema dos LLMs (como o ChatGPT): as "alucinações" e o desconhecimento de dados privados da empresa. Em vez de treinar o modelo do zero, o RAG funciona como um "livro de consultas" aberto na mesa da IA. O SQL Server 2025 se torna o motor perfeito para essa arquitetura, atuando como o repositório de conhecimento que alimenta o LLM com contexto preciso no momento exato da pergunta.

### 🧠 ENTENDA
A engenharia por trás do RAG no banco de dados se divide em três etapas fundamentais:
1. **Chunking (Fragmentação):** Documentos gigantes (PDFs, manuais) são quebrados em pedaços menores (chunks) para caberem no limite de tokens do LLM e manterem o contexto focado.
2. **Preparação de Embeddings:** Cada "chunk" de texto é transformado em um vetor matemático usando um modelo de IA.
3. **Recuperação Semântica:** Quando o usuário faz uma pergunta, o sistema transforma a pergunta em vetor e usa o SQL Server (via DiskANN) para encontrar os "chunks" de documentos que possuem o significado mais próximo, enviando apenas eles para o LLM gerar a resposta final.

### ⚡ EXECUTE SEU CÓDIGO
No SQL Server 2025, podemos criar a estrutura de armazenamento do RAG e usar a função `STRING_AGG` para concatenar os chunks recuperados, formatando o contexto perfeito antes de enviar para a API do LLM.

```sql
-- 1. CRIANDO A ESTRUTURA DE CHUNKS PARA O RAG
CREATE TABLE KnowledgeBase_RAG (
    ChunkId INT IDENTITY(1,1) PRIMARY KEY,
    DocumentoOrigem VARCHAR(100),
    Pagina INT,
    TextoChunk VARCHAR(2000), -- Tamanho ideal para um chunk
    VetorChunk VECTOR(1536)
);
GO

-- 2. SIMULANDO A INSERÇÃO DE DADOS JÁ PROCESSADOS PELO SEU APP (C#/Python)
INSERT INTO KnowledgeBase_RAG (DocumentoOrigem, Pagina, TextoChunk, VetorChunk)
VALUES 
('Manual_IT_V2.pdf', 10, 'Para resetar a senha do AD, o admin deve acessar o Active Directory...', '[0.11, -0.22, 0.33, ...]'),
('Manual_IT_V2.pdf', 15, 'O procedimento de backup ocorre às 02h da manhã todos os domingos...', '[0.44, -0.55, 0.66, ...]');
GO

-- 3. A MAGIA DO RAG: RECUPERAÇÃO E CONCATENAÇÃO PARA O LLM
-- O usuário perguntou: "Como faço para resetar a senha?"
-- A aplicação converteu essa pergunta em um vetor e enviou para o banco:
DECLARE @VetorPerguntaUsuario VECTOR(1536) = '[0.10, -0.20, 0.30, ...]';

-- Recuperamos os Top 3 chunks mais relevantes e já os juntamos em um único texto
DECLARE @ContextoParaLLM NVARCHAR(MAX);

SELECT @ContextoParaLLM = STRING_AGG(TextoChunk, ' | ') -- Separando os chunks com um delimitador
FROM (
    SELECT TOP 3 TextoChunk
    FROM KnowledgeBase_RAG
    ORDER BY VECTOR_DISTANCE('cosine', VetorChunk, @VetorPerguntaUsuario) ASC
) AS TopChunks;

-- Resultado: A variável @ContextoParaLLM agora contém o texto exato que sua aplicação 
-- vai enviar no prompt para o ChatGPT/Copilot responder ao usuário com segurança.
SELECT @ContextoParaLLM AS PromptContextoEnviadoParaLLM;
GO