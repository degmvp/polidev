#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_04 - Leitura e Escrita Direta de Arquivos
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Ler e escrever arquivos de texto em uma única linha de código.
# O fim do verboso FileReader/BufferedReader para operações simples.
#
# ATENÇÃO:
# Esses métodos carregam o arquivo inteiro na memória RAM.
# Para arquivos gigantescos (ex: logs de vários GB), prefira
# usar as linhas de Stream (Files.lines).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > FileDemo.java << 'EOF'
import java.nio.file.Files;
import java.nio.file.Path;
import java.io.IOException;

public class FileDemo {
    public static void main(String[] args) throws IOException {
        Path arquivo = Path.of("polydev_dados.txt");

        String conteudo = "Registro de Segurança 1: Acesso Liberado\nRegistro de Segurança 2: Firewall Ativo";

        // Java 11: Escrita em UMA linha
        Files.writeString(arquivo, conteudo);

        // Java 11: Leitura em UMA linha
        String lido = Files.readString(arquivo);

        System.out.println("Arquivo gerado e lido com sucesso:");
        System.out.println(lido);
    }
}
EOF

javac FileDemo.java
java FileDemo

rm -f *.class *.java *.txt && cd .. && rmdir polydev_jv11