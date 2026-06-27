#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_07 - Stream.toList() (Fim do Collector Verboso)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Simplificar a transformação de Streams em Listas.
# O antigo .collect(Collectors.toList()) era doloroso de
# digitar e exigia um import enorme.
#
# ATENÇÃO:
# Diferente do antigo Collector, o novo .toList() retorna
# uma Lista IMUTÁVEL. Qualquer tentativa de .add() falhará.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > StreamToList.java << 'EOF'
import java.util.List;
import java.util.stream.Stream;

public class StreamToList {
    public static void main(String[] args) {
        Stream<String> linguagens = Stream.of("Java", "Rust", "Golang");

        // JAVA 8 a 16: Exigia importar java.util.stream.Collectors
        // List<String> lista = linguagens.filter(s -> s.startsWith("G")).collect(Collectors.toList());

        // JAVA 17: Direto ao ponto, sem imports extras
        List<String> lista = linguagens.filter(s -> s.length() > 3).toList();

        System.out.println("Lista imutável gerada: " + lista);
    }
}
EOF

javac StreamToList.java
java StreamToList

rm -f *.class *.java && cd .. && rmdir polydev_jv17