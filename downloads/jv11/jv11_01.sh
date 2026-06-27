#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_01 - Single-File Source-Code Programs (Launcher)
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar a capacidade de executar arquivos .java diretamente
# na JVM sem a necessidade explícita do passo de compilação (javac).
# A JVM compila em memória e executa em seguida.
#
# ATENÇÃO:
# Isso funciona APENAS se o arquivo tiver uma única classe pública
# e o nome do arquivo bater exatamente com o nome da classe.
# Em projetos reais com múltiplos arquivos, use o javac normal.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Criar diretório de testes
# ==========================================================
mkdir -p polydev_jv11 && cd polydev_jv11

# ==========================================================
# ETAPA 02. Criar o código-fonte Java
# ==========================================================
cat > PolydevApp.java << 'EOF'
public class PolydevApp {
    public static void main(String[] args) {
        System.out.println("=========================================");
        System.out.println(" POLYDEV - Java 11 Single-File Launch");
        System.out.println(" Executado diretamente sem gerar .class");
        System.out.println("=========================================");
        
        // Validação de argumentos para provar que é um programa real
        if (args.length > 0) {
            System.out.println("Argumento recebido via terminal: " + args[0]);
        } else {
            System.out.println("Nenhum argumento passado. Experimente: java PolydevApp.java TESTE");
        }
    }
}
EOF

# ==========================================================
# ETAPA 03. Executar diretamente (Novidade Java 11)
# ==========================================================
echo "=== FORMA ANTIGA (Java 10 e anteriores) ==="
echo "1. javac PolydevApp.java"
echo "2. java PolydevApp"
echo ""

echo "=== FORMA NOVA JAVA 11 (Single-File) ==="
java PolydevApp.java "POLYDEV_ARQUITETURA"

# ==========================================================
# ETAPA 04. Prova conceitual (A ausência do .class)
# ==========================================================
echo ""
echo "=== VERIFICAÇÃO DE ARQUIVOS NO DIRETÓRIO ==="
ls -lha

echo ""
echo "[CONCLUSÃO] Observe que existe apenas o PolydevApp.java."
echo "Nenhum arquivo .class foi gerado no seu disco. A compilação ocorreu na memória da JVM."

# ==========================================================
# ETAPA 05. Limpeza
# ==========================================================
rm -f *.java && cd .. && rmdir polydev_jv11