#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_03 - Pattern Matching para instanceof
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Unir a verificação de tipo (instanceof) e o cast (conversão)
# em uma única operação, eliminando variáveis temporárias inúteis.
#
# ATENÇÃO:
# A variável de escopo (ex: 's') só existe dentro do bloco 'if'.
# Fora dele, ela não é reconhecida pelo compilador.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > PatternDemo.java << 'EOF'
public class PatternDemo {
    public static void processar(Object obj) {
        // JAVA 8-15: Verificava e depois fazia o cast manualmente
        // if (obj instanceof String) {
        //     String s = (String) obj;
        //     System.out.println(s.length());
        // }

        // JAVA 17: Verifica, faz o cast e cria a variável 's' na mesma linha
        if (obj instanceof String s) {
            System.out.println("É uma String de tamanho: " + s.length());
        } else if (obj instanceof Integer i) {
            System.out.println("É um Integer com valor: " + i);
        } else {
            System.out.println("Tipo desconhecido");
        }
    }

    public static void main(String[] args) {
        processar("POLYDEV Engineering");
        processar(100);
        processar(3.14);
    }
}
EOF

javac PatternDemo.java
java PatternDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17