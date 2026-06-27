#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_03 - Application Class-Data Sharing (CDS)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Reduzir o tempo de inicialização e o footprint de memória
# compartilhando classes base entre múltiplas JVMs.
#
# ATENÇÃO:
# Muito útil em ambientes Cloud/Containers onde múltiplas
# instâncias da mesma aplicação rodam no mesmo host.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > CdsDemo.java << 'EOF'
public class CdsDemo {
    public static void main(String[] args) {
        System.out.println("POLYDEV - Testando CDS");
    }
}
EOF

javac CdsDemo.java

echo "=== 1. GERANDO LISTA DE CLASSES CARREGADAS ==="
java -Xshare:off -XX:DumpLoadedClassList=classes.lst CdsDemo

echo "=== 2. CRIANDO ARQUIVO DE COMPARTILHAMENTO (ARCHIVE) ==="
java -Xshare:dump -XX:SharedClassListFile=classes.lst -XX:SharedArchiveFile=cds.jsa -cp .

echo "=== 3. RODANDO COM O CDS ATIVADO ==="
# O tempo de inicialização será visivelmente menor
time java -Xshare:on -XX:SharedArchiveFile=cds.jsa CdsDemo

rm -f *.class *.java *.lst *.jsa && cd .. && rmdir polydev_jv10