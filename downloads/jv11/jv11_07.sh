#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_07 - O Fim da Dupla Negação (Optional.isEmpty)
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Adicionar o método isEmpty() ao Optional. Antes, verificr
# se um Optional não tinha valor exigia uma dupla negação
# confusa (!optional.isPresent()), que prejudica a leitura.
#
# ATENÇÃO:
# Em regras de negócio complexas, duplas negações aumentam
# drasticamente a chance de bugs lógicos em auditorias.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > OptionalIsEmpty.java << 'EOF'
import java.util.Optional;

public class OptionalIsEmpty {
    public static void verificarUsuario(String username) {
        // Simula um banco de dados que pode não encontrar o usuário
        Optional<String> user = Optional.ofNullable(username);

        // JAVA 8: Dupla negação (Difícil de ler)
        if (!user.isPresent()) {
            System.out.println("[JAVA 8] Erro lógico: O usuário NÃO está ausente? Confuso.");
        }

        // JAVA 11: Afirmação positiva (Limpo e direto)
        if (user.isEmpty()) {
            System.out.println("[JAVA 11] Lógica clara: O usuário está ausente.");
        }
    }

    public static void main(String[] args) {
        verificarUsuario(null);
    }
}
EOF

javac OptionalIsEmpty.java
java OptionalIsEmpty

rm -f *.class *.java && cd .. && rmdir polydev_jv11