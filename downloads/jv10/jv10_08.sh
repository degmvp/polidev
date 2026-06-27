#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_08 - Transferência de Dados I/O (Reader.transferTo)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# O Java 9 introduziu InputStream.transferTo(). O Java 10
# expandiu isso adicionando Reader.transferTo(), permitindo
# copiar caracteres (texto) diretamente sem loops manuais.
#
# ATENÇÃO:
# Isso simplifica e otimiza a transferência de caracteres,
# eliminando a necessidade de loops manuais de leitura e escrita.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

# Cria um arquivo de texto de teste
echo "POLYDEV Engineering\nJava 10 I/O Optimization\nLinha de teste para transferência." > origem.txt

cat > TransferDemo.java << 'EOF'
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Reader;
import java.io.Writer;

public class TransferDemo {
    public static void main(String[] args) throws Exception {
        // Abre os arquivos para leitura e escrita
        try (Reader reader = new FileReader("origem.txt");
             Writer writer = new FileWriter("destino.txt")) {
            
            // Java 10: Transfere todo o conteúdo diretamente
            long caracteresTransferidos = reader.transferTo(writer);
            System.out.println("Arquivo transferido com sucesso. Caracteres copiados: " + long caracteresTransferidos);
        }
    }
}
EOF

javac TransferDemo.java
java TransferDemo

echo "=== CONTEÚDO DO ARQUIVO DESTINO ==="
cat destino.txt

rm -f *.class *.java origem.txt destino.txt && cd .. && rmdir polydev_jv10