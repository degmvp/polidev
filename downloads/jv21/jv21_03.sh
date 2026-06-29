JV21_03 - Scoped Values

Descrição: (Feature Preview - requer --enable-preview). É a evolução segura e performática do ThreadLocal. Enquanto o ThreadLocal é mutável e pode causar vazamentos de memória se não for limpado, o Scoped Value é imutável e boundado (existe apenas dentro de um bloco de código específico). É perfeito para passar dados de contexto (como usuário logado ou ID de transação) por pilhas de chamadas profundas sem precisar poluir os parâmetros dos métodos.

public class ScopedValuesExample {
    // Define o Scoped Value
    private static final ScopedValue<String> CURRENT_USER = ScopedValue.newInstance();

    public static void main(String[] args) {
        // Vincula o valor ao escopo
        ScopedValue.where(CURRENT_USER, "João Silva").run(() -> {
            processRequest(); // Qualquer método chamado daqui consegue ler o valor
        });
        // Fora do bloco run(), o CURRENT_USER não existe mais (zero risco de leak)
    }

    static void processRequest() {
        // Lê o valor de forma imutável e segura
        System.out.println("Processando requisição para: " + CURRENT_USER.get());
    }
}