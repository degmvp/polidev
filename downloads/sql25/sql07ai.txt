# 🚀 SQL SERVER 2025: A EVOLUÇÃO DOS DADOS
**Arquivo:** SQL07AI 
**Repositório:** Polydev Open Source Ecosystem
**Tema:** Tempo Real (Change Event Streaming)

> *"LEIA - ENTENDA - EXECUTE SEU CÓDIGO"*

### 📖 LEIA
Historicamente, para saber se uma linha foi inserida, atualizada ou deletada no banco de dados, os sistemas precisavam "puxar" (polling) essa informação através de *triggers*, *Change Data Capture (CDC)* lido por jobs, ou consultando colunas de data de alteração. O SQL Server 2025 inverte essa lógica com o **Change Event Streaming**. Agora, o próprio banco de dados funciona como um publicador nativo, "empurrando" (push) eventos de mudança de dados em tempo real diretamente para brokers de mensagens como o Azure Event Hubs ou Apache Kafka.

### 🧠 ENTENDA
Essa funcionalidade é o sonho de quem construiu Arquiteturas Orientadas a Eventos (Event-Driven Architecture) ou Microsserviços. 
1. **Push Assíncrono:** Quando um `INSERT`, `UPDATE` ou `DELETE` ocorre, o SQL Server gera um evento em segundo plano e o envia para fora, sem pesar na transação principal do usuário (zero impacto na OLTP).
2. **Sem Middlewares Pesados:** Você não precisa mais do Azure Data Factory, do Debezium ou de aplicações C# lendo tabelas de log para conectar seu banco a um Hub de Eventos. A conexão é nativa no motor relacional.
3. **Controle Granular de Payload:** Você define exatamente quais colunas serão enviadas no JSON do evento, evitando o vazamento de dados sensíveis e mantendo o payload leve para a rede.

### ⚡ EXECUTE SEU CÓDIGO
Abaixo, demonstramos como configurar o SQL Server 2025 para transmitir automaticamente qualquer alteração em uma tabela de pedidos para o Azure Event Hubs, usando a nova sintaxe T-SQL de streaming.

```sql
-- 1. CRIANDO A TABELA QUE SERÁ O "ORIGEM" DOS EVENTOS
CREATE TABLE Pedidos (
    PedidoId INT IDENTITY(1,1) PRIMARY KEY,
    ClienteId INT,
    ValorTotal DECIMAL(18,2),
    Status VARCHAR(50)
);
GO

-- 2. CRIANDO O EVENT STREAM (A mágica do SQL Server 2025)
-- Associamos a tabela Pedidos a um Endpoint externo (Azure Event Hubs)
CREATE EVENT STREAM ES_PedidosEmTempoReal
ON TABLE Pedidos
TO EXTERNAL EVENT HUB [MeuEventHubNamespace]
WITH (
    CREDENTIAL = [AzureEventHub_Cred], -- Credencial criada previamente
    TOPIC = 'topico-pedidos-novos',
    -- Mapeamos o que vai no JSON do evento. 
    -- $operation e $timestamp são variáveis nativas do sistema de streaming
    PROPERTIES (
        IdDoPedido = PedidoId,
        Cliente = ClienteId,
        Valor = ValorTotal,
        TipoMudanca = $operation, -- Irá retornar 'INSERT', 'UPDATE' ou 'DELETE'
        MomentoExato = $timestamp
    )
);
GO

-- 3. INICIANDO O STREAMING
-- Por padrão, pode estar pausado. Nós ativamos a transmissão em tempo real.
ALTER EVENT STREAM ES_PedidosEmTempoReal SET (STATE = STARTED);
GO

-- 4. TESTANDO NA PRÁTICA
-- Basta fazer um INSERT normal no SQL Server. O banco cuida do resto!
INSERT INTO Pedidos (ClienteId, ValorTotal, Status)
VALUES (42, 1500.00, 'APROVADO');

-- NESTE EXATO MILISSEGUNDO, O SQL SERVER ENVIOU O JSON ABAIXO PARA O EVENT HUB:
-- {
--   "IdDoPedido": 1,
--   "Cliente": 42,
--   "Valor": 1500.00,
--   "TipoMudanca": "INSERT",
--   "MomentoExato": "2025-10-25T14:32:10.1234567Z"
-- }