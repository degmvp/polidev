#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_06 - Otimização de Conversão Collections para Arrays
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar a nova sobrecarga do método toArray(IntFunction).
# Antes do Java 11, passar um array vazio (new String[0]) gerava
# um lixo de alocação temporária que o GC tinha que limpar.
#
# ATENÇÃO:
# A nova sintaxe (String[]::new) permite que a JVM aloque
# o array exato no tamanho correto de uma só vez (Zero Waste).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > ArrayOptimization.java << 'EOF'
import java.util.List;

public class ArrayOptimization {
    public static void main(String[] args) {
        List<String> polydevStack = List.of("Java", "Kali", "PostgreSQL", "Golang");

        // FORMA ANTIGA (Java 8)
        // Cria um array temporário de tamanho 0, depois a JVM descarta e cria um de tamanho 4.
        String[] arrayAntigo = polydevStack.toArray(new String[0]);

        // FORMA NOVA (Java 11)
        // Usa o construtor de referência para alocar o array no tamanho exato diretamente.
        String[] arrayNovo = polydevStack.toArray(String[]::new);

        System.out.println("Array otimizado gerado:");
        for (String tech : arrayNovo) {
            System.out.println(" - " + tech);
        }
    }
}
EOF

javac ArrayOptimization.java
java ArrayOptimization

rm -f *.class *.java && cd .. && rmdir polydev_jv11