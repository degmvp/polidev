# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL01AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Banco Vetorial Nativo (Native Vector Database)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O SQL Server 2025 marca uma mudança de paradigma: ele deixa de ser apenas um sistema gerenciador de banco de dados relacional para se tornar uma plataforma de IA completa. A grande novidade é a introdução do **Banco de Dados Vetorial Nativo**. Até então, para criar aplicações de IA Generativa (como chatbots semânticos ou busca de documentos), você precisava de um banco relacional (SQL Server) para seus dados estruturados e um banco vetorial externo (como Pinecone ou Milvus) para armazenar os *embeddings*. Agora, o SQL Server unifica isso.

### 🧠 ENTENDA
A mágica acontece em três pilares técnicos:
1. **Tipo de Dado VECTOR:** Um novo tipo de dado nativo otimizado para armazenar arrays de alta dimensionalidade (ex: vetores de 1536 dimensões gerados pelo modelo text-embedding-ada-002 da OpenAI).
2. **Funções Vetoriais:** Operações matemáticas nativas no T-SQL para calcular a distância entre vetores (Cosseno, Euclidiana, Produto Interno).
3. **Índices DiskANN:** O coração da performance. O DiskANN (Disk-based Approximate Nearest Neighbor) é um algoritmo de indexação criado pela Microsoft que permite buscar similaridades em milhões de vetores de forma absurdamente rápida, consumindo muito menos memória RAM que os índices baseados puramente em memória (HNSW).

### ⚡ EXECUTE SEU CÓDIGO
Abaixo, demonstramos na prática como criar a infraestrutura, indexar e realizar uma Semantic Search (Busca Semântica) inteiramente dentro do T-SQL.

```sql
-- 1. CRIANDO A TABELA COM O NOVO TIPO VECTOR
-- Exemplo usando 1536 dimensões (Padrão de modelos de linguagem modernos)
CREATE TABLE BaseConhecimento (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TituloArtigo VARCHAR(255),
    ConteudoTexto VARCHAR(MAX),
    VetorEmbedding VECTOR(1536) -- Novo tipo de dado no SQL Server 2025
);
GO

-- 2. POPULANDO DADOS (Os vetores geralmente são gerados no C#/Python e enviados para o banco)
INSERT INTO BaseConhecimento (TituloArtigo, ConteudoTexto, VetorEmbedding)
VALUES (
    'Introdução ao SQL Server 2025',
    'O SQL Server 2025 traz funcionalidades inéditas de inteligência artificial...',
    '[0.0231, -0.0489, 0.1123, ... /* 1536 valores float */ ]'
);
GO

-- 3. CRIANDO O ÍNDICE DISKANN (Essencial para performance em larga escala)
-- Define o algoritmo de similaridade (Cosine é o padrão para textos)
CREATE VECTOR INDEX IX_BaseConhecimento_Vetor 
ON BaseConhecimento (VetorEmbedding)
WITH (METRIC = 'cosine');
GO

-- 4. REALIZANDO A BUSCA SEMÂNTICA (Similaridade)
-- O usuário faz uma pergunta, ela vira um vetor na aplicação, e buscamos os melhores resultados
DECLARE @VetorDaPerguntaDoUsuario VECTOR(1536) = '[0.0250, -0.0500, 0.1100, ... ]';

SELECT TOP 5 
    TituloArtigo,
    ConteudoTexto,
    -- VECTOR_DISTANCE calcula a proximidade. Quanto MENOR o valor, MAIOR a similaridade!
    VECTOR_DISTANCE('cosine', VetorEmbedding, @VetorDaPerguntaDoUsuario) AS ScoreSimilaridade
FROM BaseConhecimento
ORDER BY ScoreSimilaridade ASC; -- Ordena do mais parecido para o menos parecido
GO