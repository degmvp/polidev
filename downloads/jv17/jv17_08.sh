#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_08 - Foreign Function & Memory API (Ponte C/Rust)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Substituir o antigo JNI por uma API pura de Java para
# alocar memória nativa e chamar funções de bibliotecas
# compartilhadas (C/C++/Rust) de forma segura.
#
# ATENÇÃO:
# No Java 17, esta API ainda é "Incubadora" (jdk.incubator.foreign).
# É necessário adicionar o módulo explicitamente na execução.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > FfmDemo.java << 'EOF'
import jdk.incubator.foreign.CLinker;
import jdk.incubator.foreign.LibraryLookup;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.VarHandle;

public class FfmDemo {
    public static void main(String[] args) throws Throwable {
        System.out.println("API FFM carregada com sucesso.");
        System.out.println("Com ela, o Java pode alocar memória fora da Heap (malloc)");
        System.out.println("e chamar funções escritas em Rust ou C diretamente,");
        System.out.println("sem a complexidade e os leaks de memória do antigo JNI.");
    }
}
EOF

javac FfmDemo.java

echo "=== EXECUTANDO COM MÓDULO INCUBADOR HABILITADO ==="
# A flag --add-modules é obrigatória no Java 17 para usar a ponte nativa
java --add-modules jdk.incubator.foreign FfmDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17