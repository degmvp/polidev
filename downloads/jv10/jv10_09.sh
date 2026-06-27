#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_09 - JIT Compiler Experimental (Graal)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Habilitar o compilador JIT Graal (escrito em Java) em vez
# do C2 tradicional (escrito em C++). O Graal permite
# otimizações agressivas de código em tempo de execução.
#
# ATENÇÃO:
# No Java 10, o Graal é estritamente experimental. Requer
# flags específicas para ser ativado. Pode causar instabilidade
# em código de produção não testado.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > GraalDemo.java << 'EOF'
public class GraalDemo {
    public static void main(String[] args) {
        long inicio = System.currentTimeMillis();
        double resultado = 0;
        
        // Loop computacional pesado para dar trabalho ao JIT Compiler
	for (int i = 0; i < 500_000_000; i++) {
   	 resultado += Math.sqrt(i);
	}
        long fim = System.currentTimeMillis();
        System.out.println("Resultado: " + resultado);
        System.out.println("Tempo de execução (com JIT): " + (fim - inicio) + " ms");
    }
}
EOF

javac GraalDemo.java

echo "=== EXECUTANDO COM JIT TRADICIONAL (C2) ==="
java GraalDemo

echo -e "\n=== EXECUTANDO COM JIT EXPERIMENTAL GRAAL ==="
# Flags necessárias para ativar o Graal no Java 10
java -XX:+UnlockExperimentalVMOptions -XX:+UseJVMCICompiler GraalDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv10