#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_03 - Novos Métodos na Classe String
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Eliminar a necessidade de usar bibliotecas externas (como
# Apache Commons Lang) para tarefas básicas de manipulação
# de texto com métodos nativos otimizados na JVM.
#
# ATENÇÃO:
# O método strip() é "Unicode-aware", diferente do trim()
# que remove apenas caracteres ASCII abaixo de 'U+0020'.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > StringDemo.java << 'EOF'
public class StringDemo {
    public static void main(String[] args) {
        String espaco = "   POLYDEV   ";
        String vazia = "   \n\t  ";
        String multipla = "Linha1\nLinha2\nLinha3";

        System.out.println("--- STRIP (Unicode Aware) ---");
        System.out.println("Original: '" + espaco + "'");
        System.out.println("strip():  '" + espaco.strip() + "'");

        System.out.println("\n--- ISBLANK ---");
        System.out.println("String vazia tem conteúdo visível? " + !vazia.isEmpty());
        System.out.println("String vazia é branca (blank)? " + vazia.isBlank());

        System.out.println("\n--- LINES (Split em Stream) ---");
        // Transforma quebras de linha em um Stream elegante
        multipla.lines().forEach(linha -> System.out.println("Linha processada: " + linha));

        System.out.println("\n--- REPEAT ---");
        String traco = "-".repeat(20);
        System.out.println(traco);
    }
}
EOF

javac StringDemo.java
java StringDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv11