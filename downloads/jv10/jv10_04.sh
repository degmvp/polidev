#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_04 - Coleções Imutáveis (copyOf)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Criar cópias imutáveis de coleções de forma limpa e
# segura contra modificações externas (Thread-Safety).
#
# ATENÇÃO:
# Qualquer tentativa de add(), put() ou remove() em uma
# coleção gerada por copyOf() lançará UnsupportedOperationException.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > CopyOfDemo.java << 'EOF'
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CopyOfDemo {
    public static void main(String[] args) {
        // Cria coleções mutáveis
        List<String> mutList = List.of("A", "B");
        Set<String> mutSet = Set.of("X", "Y");
        Map<String, String> mutMap = Map.of("K1", "V1");

        // Java 10: Cria cópias estritamente imutáveis
        List<String> imutList = List.copyOf(mutList);
        Set<String> imutSet = Set.copyOf(mutSet);
        Map<String, String> imutMap = Map.copyOf(mutMap);

        System.out.println("List: " + imutList);
        System.out.println("Set: " + imutSet);
        System.out.println("Map: " + imutMap);

        try {
            imutList.add("C"); // Isso vai falhar
        } catch (UnsupportedOperationException e) {
            System.out.println("\n[ERRO ESPERADO] Imutabilidade garantida: " + e.getClass().getSimpleName());
        }
    }
}
EOF

javac CopyOfDemo.java
java CopyOfDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv10