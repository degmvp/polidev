#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_05 - Inferência de Tipo no Lambda (var)
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Permitir o uso do 'var' em parâmetros de expressões Lambda.
# Isso é obrigatório quando precisamos adicionar anotações
# (@NotNull, por exemplo) nos parâmetros do Lambda.
#
# ATENÇÃO:
# O uso de 'var' no Lambda NÃO pode misturar tipos declarados
// e inferidos. Ex: (var x, String y) é erro de compilação.
# Deve ser tudo 'var' ou tudo explícito.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > LambdaVarDemo.java << 'EOF'
import java.util.List;

public class LambdaVarDemo {
    public static void main(String[] args) {
        List<String> tecnologias = List.of("Kali", "PostgreSQL", "Java 11");

        System.out.println("--- Lambda Tradicional ---");
        tecnologias.stream().forEach((String tech) -> System.out.println("Stack: " + tech));

        System.out.println("\n--- Lambda com 'var' (Java 11) ---");
        // O uso de 'var' aqui deixa o código mais limpo visualmente
        tecnologias.stream().forEach((var tech) -> System.out.println("Stack: " + tech));

        System.out.println("\n--- O Verdadeiro Motivo: Anotações ---");
        // Sem o 'var', não há como colocar uma anotação no tipo do parâmetro
        tecnologias.stream().forEach((@Deprecated var tech) -> {
            System.out.println("Aviso: Usando tecnologia antiga -> " + tech);
        });
    }
}
EOF

javac LambdaVarDemo.java
java LambdaVarDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv11