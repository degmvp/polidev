#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_07 - Parallel Full GC no Coletor G1
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# No Java 9, um Full GC no G1 era single-threaded (travava tudo).
# No Java 10, o Parallel Full GC foi implementado, acelerando
# a recuperação de memória em cenários de estresse extremo.
#
# ATENÇÃO:
# Vamos forçar um esgotamento de memória com uma Heap pequena
# para observar o comportamento do GC em tempo real.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > ParallelGC.java << 'EOF'
import java.util.ArrayList;
import java.util.List;

public class ParallelGC {
    public static void main(String[] args) {
        List<byte[]> data = new ArrayList<>();
        try {
            // Loop infinito para forçar o esgotamento da Heap (Setada para 32MB no bash)
            while (true) {
                data.add(new byte[1024 * 1024]); // Aloca 1MB por iteração
            }
        } catch (OutOfMemoryError e) {
            System.out.println("Memória esgotada. Full GC foi acionado parallelamente pela JVM.");
        }
    }
}
EOF

javac ParallelGC.java

echo "=== FORÇANDO FULL GC COM HEAP DE 32MB ==="
# -Xmx32m limita a memória para forçar o GC mais rápido
# -Xlog:gc* mostra as threads do GC trabalhando em paralelo
java -Xmx32m -Xlog:gc*:file=gc_parallel.log ParallelGC

echo "Verifique o log 'gc_parallel.log' e procure por 'Parallel GC' ou múltiplas threads trabalhando."
tail -n 3 gc_parallel.log

rm -f *.class *.java *.log && cd .. && rmdir polydev_jv10