#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_10 - Limpa Arquitetural (Remoção do Java EE)
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# O Java 11 removeu pacotes inteiros do núcleo (java.xml.ws,
# java.xml.bind, etc) que faziam parte do Java EE. O objetivo
# foi aliviar o peso do JDK, deixando-o focado apenas no Core.
#
# ATENÇÃO:
# Se você migrar um sistema antigo (Java 8) para o 11 e usar
# JAXB ou JAX-WS, o código NÃO VAI COMPILAR. A solução não é
# voltar a versão, mas adicionar essas dependências via Maven
# ou Gradle (jakarta.xml.bind).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > RemocaoJavaEE.java << 'EOF'
// Tentativa de importar uma classe do JAXB removida no Java 11
import javax.xml.bind.JAXBContext;

public class RemocaoJavaEE {
    public static void main(String[] args) {
        System.out.println("Se você está lendo isso, o Java EE ainda está presente.");
    }
}
EOF

echo "=== TENTATIVA DE COMPILAÇÃO COM API REMOVIDA ==="
javac RemocaoJavaEE.java 2>&1

echo ""
echo "[ANÁLISE] Observe o erro: 'package javax.xml.bind does not exist'."
echo "No Java 8 este código compilava. No Java 11, a dependência foi removida do JDK core."
echo "A arquitetura ficou mais limpa e leve para microsserviços modernos."

rm -f *.java && cd .. && rmdir polydev_jv11