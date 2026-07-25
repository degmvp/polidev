# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL09AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Segurança (Microsoft Entra, Enclaves e Governança)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
O SQL Server 2025 dá um passo definitivo rumo à arquitetura "Zero Trust" (Confiança Zero). A era de depender de logins nativos do SQL Server (`sa`, usuários com senha no banco) está chegando ao fim para ambientes corporativos modernos. A segurança agora é orientada por identidade e criptografia profunda. O foco não é apenas impedir que alguém quebre a senha, mas garantir que, mesmo que um administrador malicioso ou um invasor roube os arquivos físicos do banco de dados (os arquivos .mdf/.ldf), os dados sejam absolutamente inúteis e ilegíveis para ele.

### 🧠 ENTENDA
A pilha de segurança do SQL Server 2025 é fortalecida por três grandes pilares:
1. **Identidades Gerenciadas Microsoft Entra (ex-Azure AD):** Permite que aplicações hospedadas no Azure (ou até on-premise integrados ao Entra ID) se autentiquem no banco de dados sem senhas. A identidade da aplicação é gerenciada pelo sistema operacional/cloud, eliminando o risco de vazamento de *connection strings* com senhas hardcoded.
2. **Always Encrypted com Secure Enclaves:** O maior salto criptográfico. Antes, dados criptografados pelo cliente não podiam ser usados em cláusulas `WHERE` ou `GROUP BY` (o banco não sabia ler o dado). Com os *Secure Enclaves*, o SQL Server 2025 cria uma área segura e isolada na memória RAM. Ele consegue descriptografar o dado dentro dessa "caixa forte" em tempo real, fazer a busca, e retornar o resultado, sem que o dado em texto claro jamais toque no disco ou fique visível para um DBA.
3. **Governança e Ledger:** Evolução do Database Ledger para garantir imutabilidade de dados sensíveis, gerando um hash criptográfico inquebrável que prova que um registro de auditoria ou financeiro nunca foi alterado.

### ⚡ EXECUTE SEU CÓDIGO
Abaixo, demonstramos como eliminar senhas do seu ambiente e como configurar criptografia que permite buscas seguras (Enclaves).

```sql
-- 1. SEGURANÇA SEM SENHAS: CRIANDO UM USUÁRIO VIA MICROSOFT ENTRA ID
-- Sua aplicação no Azure App Service tem uma "Identidade Gerenciada" atribuída.
-- Você mapeia essa identidade diretamente no banco. Sem senha, sem segredo.
CREATE USER [SuaApp-Managed-Identity-Name] 
FROM EXTERNAL PROVIDER; -- Conecta diretamente com o Microsoft Entra ID

-- Dá permissão apenas para o esquema de vendas (Princípio do Menor Privilégio)
ALTER ROLE db_datareader ADD MEMBER [SuaApp-Managed-Identity-Name];
GO

-- 2. CRIPTOGRAFIA AVANÇADA: ALWAYS ENCRYPTED COM SECURE ENCLAVES
-- Passo A: Criar uma chave de criptografia de coluna habilitada para Enclave
-- (Isso seria feito via SSMS ou Azure Key Vault, mas a sintaxe conceitual T-SQL é:)
CREATE COLUMN ENCRYPTION KEY CEK_DadosFinanceiros
WITH VALUES (
    COLUMN_MASTER_KEY = CMK_AzureKeyVault,
    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',
    ENCLAVE_COMPUTATIONS = ON -- O segredo para permitir buscas no dado criptografado!
);

-- Passo B: Criando a tabela com colunas criptografadas
CREATE TABLE FolhaDePagamento (
    FuncionarioId INT PRIMARY KEY,
    Nome VARCHAR(100),
    -- O dado chega criptografado do app e só é decriptado dentro do Enclave na memória RAM
    SalarioBase DECIMAL(18,2) ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC, COLUMN_ENCRYPTION_KEY = CEK_DadosFinanceiros, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256')
);

-- Passo C: A MAGIA - Fazendo BUSCAS em dados criptografados!
-- No SQL Server antigo, isso daria erro ou faria Table Scan lento. 
-- No 2025 com Enclave, o banco processa a busca de forma segura e ultra rápida.
SELECT Nome, SalarioBase 
FROM FolhaDePagamento 
WHERE SalarioBase > 10000.00; -- O banco compara os valores dentro do Enclave seguro!