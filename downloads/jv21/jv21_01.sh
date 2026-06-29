JV21_01 - Virtual Threads (Project Loom)

Descrição: As Virtual Threads são threads leves gerenciadas pela JVM (e não pelo Sistema Operacional). Elas consomem pouquíssima memória (poucos quilobytes), permitindo que uma aplicação crie milhões de threads simultâneas sem causar estouro de memória (OutOfMemoryError) ou travar o SO. O objetivo principal é simplificar a programação concorrente de alta escalabilidade, eliminando a complexidade de códigos reativos (como callbacks ou CompletableFuture encadeados), mantendo a mentalidade síncrona e imperativa tradicional.

public class VirtualThreadsExample {
    public static void main(String[] args) throws InterruptedException {
        // Cria um executor que gera uma nova Virtual Thread para cada tarefa
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 1; i <= 10_000; i++) {
                final int taskId = i;
                executor.submit(() -> {
                    // Tarefa simulando uma chamada de banco de dados ou API
                    Thread.sleep(Duration.ofSeconds(1)); 
                    System.out.println("Tarefa " + taskId + " concluída por: " + Thread.currentThread());
                });
            }
        } // Fecha o executor e aguarda a conclusão de todas as 10 mil threads
    }
}