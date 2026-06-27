#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_10 - Direct Memory e ByteBuffer (NIO)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (JDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar a diferença entre Heap Memory e Direct Memory
# utilizando ByteBuffer.allocate() e
# ByteBuffer.allocateDirect().
#
# Também mostra como limitar a memória direta e observar
# o comportamento da JVM quando ela se esgota.
#
# ATENÇÃO:
# Aplicações de alta performance, servidores assíncronos,
# Netty e frameworks de I/O intensivo utilizam Direct Memory
# extensivamente.
#
# O esgotamento da Direct Memory normalmente produz:
#
# java.lang.OutOfMemoryError:
# Direct buffer memory
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > DirectMemoryDemo.java << 'EOF'
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public class DirectMemoryDemo {

public static void main(String[] args) {

    List<ByteBuffer> buffers = new ArrayList<>();

    System.out.println("Alocando buffers diretos...");

    int contador = 0;

    try {

        while (true) {
            buffers.add(
                ByteBuffer.allocateDirect(1024 * 1024)
            );

            contador++;

            System.out.println(
                "Buffer direto alocado: "
                + contador
                + " MB"
            );
        }

    } catch (OutOfMemoryError e) {

        System.out.println();
        System.out.println(
            "Direct Memory esgotada após "
            + contador
            + " MB."
        );

        System.out.println(
            "Exceção: "
            + e.getMessage()
        );
    }

    System.out.println();
    System.out.println(
    "A JVM continua viva e o erro foi tratado."
);

    }
}
EOF

javac DirectMemoryDemo.java

echo "=== LIMITANDO DIRECT MEMORY PARA 5MB ==="

java -XX:MaxDirectMemorySize=5M DirectMemoryDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv10

















