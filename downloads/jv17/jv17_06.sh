#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_06 - NullPointerExceptions Amigáveis (JEP 358)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Eliminar o clássico "Null Pointer" sem pista alguma.
# O Java 17 analisa o stack trace e te diz EXATAMENTE qual
# variável era nula, economizando horas de debug.
#
# ATENÇÃO:
# Essa funcionalidade é desativada por padrão em algumas
# distribuições para não vazar informações sensíveis em
# produção. Ative-a explicitamente com a flag mostrada abaixo.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > NpeDemo.java << 'EOF'
public class NpeDemo {
    public static void main(String[] args) {
        String texto = null;
        // Tentando chamar um método em um objeto nulo
        System.out.println(texto.length());
    }
}
EOF

javac NpeDemo.java

echo "=== FORMA ANTIGA (Sem detalhes) ==="
java NpeDemo 2>&1 | head -n 2

echo ""
echo "=== FORMA JAVA 17 (Detalhamento da JVM) ==="
# A flag -XX:+ShowCodeDetailsInExceptionMessages ativa o rastreamento preciso
java -XX:+ShowCodeDetailsInExceptionMessages NpeDemo 2>&1 | head -n 2

rm -f *.class *.java && cd .. && rmdir polydev_jv17