JV21_02 - Structured Concurrency

Descrição: (Feature Incubator - requer módulo jdk.incubator.concurrent). É uma abordagem para tratar multitarefas como uma única unidade de trabalho. Em vez de lançar threads "para o éter" e tentar rastrear seus resultados depois, você cria um "escopo". Se uma subtarefa falhar, todas as outras subtarefas do mesmo escopo são canceladas automaticamente. Isso evita thread leaks e torna o tratamento de exceções muito mais previsível.

import jdk.incubator.concurrent.StructuredTaskScope;

public class StructuredConcurrencyExample {
    public static void main(String[] args) throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            // Dispara subtarefas em paralelo
            StructuredTaskScope.Subtask<String> user = scope.fork(() -> fetchUser());
            StructuredTaskScope.Subtask<String> order = scope.fork(() -> fetchOrder());

            // Aguarda todas finalizarem. Se uma falhar, cancela a outra.
            scope.join();
            scope.throwIfFailed();

            // Combina os resultados se ambas deram certo
            System.out.println("Resultado: " + user.get() + " - " + order.get());
        }
    }
    static String fetchUser() { /* lógica */ return "UserA"; }
    static String fetchOrder() { /* lógica */ return "Order123"; }
}