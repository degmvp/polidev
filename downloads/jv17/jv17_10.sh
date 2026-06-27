#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_10 - RandomGenerator API (Aleatoriedade Moderna)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Apresentar a nova API de geração de números pseudoaleatórios
# do Java 17, baseada na interface RandomGenerator e em novos
# algoritmos modernos como L64X128MixRandom.
#
# ATENÇÃO:
# RandomGenerator é excelente para simulações, testes e cargas
# aleatórias. Para criptografia, tokens, senhas e segurança,
# use SecureRandom.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > RandomGeneratorDemo.java << 'EOF'
import java.util.random.RandomGenerator;
import java.util.random.RandomGeneratorFactory;

public class RandomGeneratorDemo {
    public static void main(String[] args) {
        RandomGenerator rng =
            RandomGeneratorFactory.of("L64X128MixRandom").create();

        System.out.println("POLYDEV | Java 17 RandomGenerator API");
        System.out.println("Algoritmo: L64X128MixRandom");

        System.out.println("\nNúmero inteiro entre 1 e 100:");
        System.out.println(rng.nextInt(1, 101));

        System.out.println("\nNúmero decimal entre 0.0 e 1.0:");
        System.out.println(rng.nextDouble());

        System.out.println("\nCinco valores simulados entre 10 e 99:");
        rng.ints(5, 10, 100)
           .forEach(System.out::println);
    }
}
EOF

javac RandomGeneratorDemo.java
java RandomGeneratorDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17