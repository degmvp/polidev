JV21_08 - Foreign Function & Memory API (FFM API)

Descrição: (Feature Preview - requer --enable-preview). Substitui a antiga e problemática JNI (Java Native Interface). Permite que o Java chame funções de bibliotecas nativas (C/C++, Rust) e aloc memória fora do Heap (memória off-heap) de forma segura, usando puramente Java API, sem escrever código C intermediário. É o motor que vai permitir que o Java concorra nativamente com Node.js e Rust em integrações de baixo nível (ex: bancos de dados vetoriais, IA, engines de jogos).

import java.lang.foreign.*;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.VarHandle;

public class FFMExample {
    public static void main(String[] args) throws Throwable {
        // 1. Linka com a biblioteca C padrão do SO (libc)
        Linker linker = Linker.nativeLinker();
        SymbolLookup stdlib = linker.defaultLookup();

        // 2. Busca a função strlen(const char *s)
        MethodHandle strlen = linker.downcallHandle(
            stdlib.lookup("strlen").orElseThrow(),
            FunctionDescriptor.of(ValueLayout.JAVA_LONG, ValueLayout.ADDRESS)
        );

        // 3. Aloca memória nativa e escreve uma string nela
        try (Arena arena = Arena.ofConfined()) {
            MemorySegment str = arena.allocateFrom("Hello FFM API!");
            
            // 4. Chama a função C nativa passando o ponteiro
            long len = (long) strlen.invoke(str);
            System.out.println("Tamanho calculado por C: " + len); // Imprime 14
        } // A memória nativa é liberada automaticamente aqui
    }
}