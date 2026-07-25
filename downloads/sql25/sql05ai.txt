# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL05AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Frameworks de IA (LangChain, Semantic Kernel, EF Core)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O SQL Server 2025 não exige que você abandone suas ferramentas de desenvolvimento favoritas para trabalhar com Inteligência Artificial. Pelo contrário, a Microsoft e a comunidade open source trabalharam para que o SQL Server 2025 funcionasse como um "cidadão de primeira classe" nos principais orquestradores de IA do mercado. Seja você um desenvolvedor Python usando LangChain ou um desenvolvedor .NET usando Semantic Kernel, o banco de dados agora conversa nativamente com essas frameworks, abstraindo a complexidade matemática dos vetores.

### 🧠 ENTENDA
A integração acontece em três níveis fundamentais para o ecossistema Polpolydev:
1. **LangChain (Python):** O SQL Server 2025 é introduzido como um "VectorStore" nativo. O desenvolvedor Python não precisa escrever uma única linha de T-SQL complexa; o LangChain usa drivers otimizados para criar tabelas, gerar embeddings e fazer buscas semânticas automaticamente.
2. **Semantic Kernel (.NET):** Por ser da própria Microsoft, a integração é profunda. O SQL Server 2025 torna-se um conector de "Memória" nativo no SK, permitindo que agentes de IA em C# lembrem do contexto das conversas armazenadas de forma persistente e segura no banco.
3. **Entity Framework Core:** Atualizações no provedor de dados do EF Core permitem mapear o novo tipo de dado `VECTOR` diretamente para propriedades no C#, usando a nova API de "Sparse Vectors" (vetores esparsos), eliminando a necessidade de conversões manuais de arrays de float para strings.

### ⚡ EXECUTE SEU CÓDIGO
Como a mágica acontece na camada de aplicação, o código abaixo demonstra como a integração parece do lado do desenvolvedor .NET usando Entity Framework Core e Semantic Kernel para salvar e buscar um vetor no SQL Server 2025 sem escrever SQL manualmente.

```csharp
// 1. MAPEAMENTO NO ENTITY FRAMEWORK CORE (C#)
// O EF Core 9+ reconhece o novo tipo VECTOR do SQL Server 2025
public class DocumentoAi
{
    public int Id { get; set; }
    public string Texto { get; set; }
    
    // Novo mapeamento nativo: Sem precisar de conversão para JSON ou VarBinary!
    public ReadOnlyMemory<float> Embedding { get; set; } 
}

// Configuração no DbContext (Fluent API)
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<DocumentoAi>()
        .Property(e => e.Embedding)
        .HasColumnType("VECTOR(1536)"); // Diz ao EF para usar o tipo nativo do SQL 2025
}

// ---------------------------------------------------------
// 2. INTEGRAÇÃO COM SEMANTIC KERNEL (Orquestrador de IA)
// O Semantic Kernel usa o EF Core por baixo dos panos
// ---------------------------------------------------------

// Registrando o SQL Server 2025 como a "Memória" do seu Agente IA
var kernel = Kernel.CreateBuilder()
    .AddAzureOpenAIChatCompletion("gpt-4", "https://seu-endpoint.azure.com")
    .Build();

// Conectando a Memória Semantic Kernel diretamente ao seu DbContext do SQL 2025
var memoryStore = new SqlServerMemoryStore(_dbContext, kernel.LoggerFactory);
var semanticMemory = new SemanticTextMemory(memoryStore, new TextEmbeddingGenerator());

// SALVANDO MEMÓRIA (O SK e o EF Core geram o T-SQL e o Embedding automaticamente)
await semanticMemory.SaveInformationAsync(
    collection: "politica-empresa", 
    text: "Férias são de 30 dias após 1 ano de empresa.",
    id: "regra-ferias-01"
);

// BUSCANDO MEMÓRIA (Busca Semântica abstraída! O SQL Server usa o DiskANN nativamente)
var resultado = await semanticMemory.SearchAsync(
    collection: "politica-empresa", 
    query: "Quantos dias de descanso eu tenho direito?", 
    limit: 1
);

Console.WriteLine(resultado.Results.First().Metadata.Text); 
// Saída: "Férias são de 30 dias após 1 ano de empresa."