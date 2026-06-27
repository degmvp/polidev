#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_05 - Optional.orElseThrow()
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Simplificar o lançamento de exceções quando um Optional
# está vazio, removendo a necessidade de Suppliers verbosos.
#
# ATENÇÃO:
# Use Optional como retorno de métodos, nunca como atributo
# de classe ou parâmetro de método (Anti-Pattern).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > OrElseThrowDemo.java << 'EOF'
import java.util.Optional;

public class OrElseThrowDemo {
    public static String buscarDadoNoBanco(int id) {
        if (id == 1) return "Dado Encontrado";
        return null;
    }

    public static void main(String[] args) {
        // Java 8/9: Forma verbosa de lançar exceção se vazio
        try {
            String res1 = Optional.ofNullable(buscarDadoNoBanco(2))
                                  .orElseThrow(() -> new IllegalArgumentException("Registro não encontrado (Antigo)"));
        } catch (Exception e) {
            System.out.println("[ANTIGO] " + e.getMessage());
        }

        // Java 10: Forma limpa e direta
        try {
            String res2 = Optional.ofNullable(buscarDadoNoBanco(2))
                                  .orElseThrow(); // Lança NoSuchElementException automaticamente
        } catch (Exception e) {
            System.out.println("[JAVA 10] Exceção limpa lançada: " + e.getClass().getSimpleName());
        }
    }
}
EOF

javac OrElseThrowDemo.java
java OrElseThrowDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv10