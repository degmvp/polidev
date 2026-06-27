#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_08 - Epsilon Garbage Collector (O GC "Nulo")
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Apresentar o Epsilon GC, um coletor de lixo que NÃO FAZ NADA.
# Ele apenas aloca memória. Útil para testes de microperformance
# extremos, onde você quer medir apenas a velocidade de alocação
# da JVM sem a interferência do tempo de limpeza do GC.
#
# ATENÇÃO:
# Ao usar o Epsilon, quando a memória acabar, a JVM crashará
# com OutOfMemoryError. NUNCA use em produção.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > EpsilonTest.java << 'EOF'
import java.util.ArrayList;
import java.util.List;

public class EpsilonTest {
    public static void main(String[] args) {
        List<byte[]> memorySink = new ArrayList<>();
        int mb = 0;
        try {
            // Loop infinito forçando alocação de memória
            while (true) {
                memorySink.add(new byte[1024 * 1024]); // 1 MB
                mb++;
            }
        } catch (OutOfMemoryError e) {
            // Como o Epsilon GC não limpa a memória, ele crashará aqui rapidamente
            System.out.println("Epsilon GC ativado. Memória alocada até o crash: " + mb + " MB");
            System.out.println("Nenhum tempo foi gasto limpando lixo (GC Pause = 0ms).");
        }
    }
}
EOF

javac EpsilonTest.java

echo "=== EXECUTANDO COM EPSILON GC (LIMITE DE 32MB) ==="
# -XX:+UnlockExperimentalVMOptions -XX:+UseEpsilonGC habilita o GC Nulo
java -Xmx32m -XX:+UnlockExperimentalVMOptions -XX:+UseEpsilonGC EpsilonTest

rm -f *.class *.java && cd .. && rmdir polydev_jv11