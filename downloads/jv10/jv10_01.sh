#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_01 - Inferência de Tipo Local (var) e Bytecode
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Desmistificar o 'var' provando que é apenas açúcar
# sintático. O bytecode gerado é estritamente tipado.
#
# ATENÇÃO:
# 'var' só funciona para variáveis locais com inicializador.
# Não use em campos de classe, parâmetros ou retornos.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > PolydevExplicit.java << 'EOF'
import java.util.ArrayList;
import java.util.List;
public class PolydevExplicit {
    public static void main(String[] args) {
        List<String> lista = new ArrayList<String>();
        lista.add("POLYDEV");
        System.out.println(lista.get(0));
    }
}
EOF

cat > PolydevInferred.java << 'EOF'
import java.util.ArrayList;
import java.util.List;
public class PolydevInferred {
    public static void main(String[] args) {
        var lista = new ArrayList<String>();
        lista.add("POLYDEV");
        System.out.println(lista.get(0));
    }
}
EOF

javac PolydevExplicit.java
javac PolydevInferred.java

echo "=== BYTECODE TIPO EXPLÍCITO ==="
javap -c PolydevExplicit.class | grep -A 4 "public static void main"

echo -e "\n=== BYTECODE TIPO INFERIDO (var) ==="
javap -c PolydevInferred.class | grep -A 4 "public static void main"

java PolydevExplicit
java PolydevInferred

rm -f *.class *.java && cd .. && rmdir polydev_jv10