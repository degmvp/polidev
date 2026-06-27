#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_02 - G1 Garbage Collector como Padrão
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar que o G1 é o padrão no Java 10, focado em
# pausas curtas e previsíveis, ideal para Low-Latency.
#
# ATENÇÃO:
# O Parallel GC focava em throughput (pausas longas).
# O G1 divide a heap em regiões, limpando o lixo aos poucos.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > G1Demo.java << 'EOF'
import java.util.ArrayList;
import java.util.List;
public class G1Demo {
    public static void main(String[] args) {
        List<byte[]> memorySink = new ArrayList<>();
        for (int i = 0; i < 1000000; i++) {
            memorySink.add(new byte[1024]); // Aloca 1MB por ciclo
            if (i % 10000 == 0) {
                memorySink.clear(); // Força o GC a limpar
            }
        }
        System.out.println("Ciclo de memória concluído.");
    }
}
EOF

javac G1Demo.java

echo "=== EXECUTANDO COM G1 (PADRÃO JAVA 10) ==="
# -Xlog:gc* mostra os logs detalhados do Garbage Collector
java -Xlog:gc*:file=gc_g1.log G1Demo
echo "Log do G1 gerado em gc_g1.log. Use: cat gc_g1.log"
tail -n 5 gc_g1.log

rm -f *.class *.java *.log && cd .. && rmdir polydev_jv10