#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_04 - Switch Expressions (Retorno Direto)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Transformar o switch de uma instrução (que precisa de break
# para não cair nos próximos cases) em uma expressão que
# retorna um valor diretamente, usando a sintaxe de seta (->).
#
# ATENÇÃO:
# Switch Expressions devem cobrir todos os casos possíveis
# (exhaustive). Se usar uma enumeração, você DEVE tratar
# todos os valores ou usar 'default'.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > SwitchDemo.java << 'EOF'
public class SwitchDemo {
    public static String getProtocolo(int porta) {
        // Switch Expression usando a sintaxe de seta (->)
        // Não precisa de 'break'. Retorna o valor direto.
        return switch (porta) {
            case 80, 8080 -> "HTTP";
            case 443, 8443 -> "HTTPS";
            case 22 -> "SSH";
            case 5432 -> "PostgreSQL";
            default -> "Desconhecido";
        };
    }

    public static void main(String[] args) {
        System.out.println("Porta 443: " + getProtocolo(443));
        System.out.println("Porta 5432: " + getProtocolo(5432));
    }
}
EOF

javac SwitchDemo.java
java SwitchDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17