#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_09 - Java Flight Recorder (JFR) Open Source
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# O JFR era o melhor profiler do mundo, mas era pago (Oracle JDK).
# No Java 11, ele se tornou Open Source. Permite gravar tudo o que
# acontece na JVM (Threads, GC, I/O, Latência) com ZERO overhead.
#
# ATENÇÃO:
# O JFR gera um arquivo binário (.jfr). Para ler, usa-se a
# ferramenta gráfica "jmc" ou o comando "jfr print" no terminal.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > JfrDemo.java << 'EOF'
public class JfrDemo {
    public static void main(String[] args) throws InterruptedException {
        System.out.println("Iniciando carga de trabalho para o JFR gravar...");
        long inicio = System.currentTimeMillis();
        
        // Simula um processamento de 3 segundos para o JFR capturar eventos
        Thread.sleep(3000);
        
        System.out.println("Carga finalizada. Verifique o arquivo polydev.gravar.");
    }
}
EOF

javac JfrDemo.java

echo "=== GRAVANDO PERFIL COM JFR ==="
# -XX:StartFlightRecording inicia o profiler no formato binário
# duration=3s limita a gravação a 3 segundos
# filename=direciona o output para o arquivo
java -XX:StartFlightRecording=duration=3s,filename=polydev.jfr JfrDemo

echo "=== CONTEÚDO GERADO ==="
ls -lh polydev.jfr

echo "=== EXTRINDO DADOS DO ARQUIVO BINÁRIO (.jfr) ==="
# O jfr print converte o binário para texto legível no terminal
jfr print --events CPULoad,GarbageCollection polydev.jfr

rm -f *.class *.java *.jfr && cd .. && rmdir polydev_jv11