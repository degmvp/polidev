#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_09 - Strong Encapsulation (JDK Blindado)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar que os pacotes internos do JDK foram fortemente
# encapsulados. O Java 17 bloqueia hacks de reflexão tentando
# acessar partes internas do núcleo da JVM.
#
# ATENÇÃO:
# Muitas bibliotecas antigas podem quebrar no Java 17 por causa
# disso. A solução correta é atualizar a biblioteca, não sair
# abrindo o JDK com --add-opens sem critério.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > EncapsulationDemo.java << 'EOF'
import java.lang.reflect.Field;
import java.lang.reflect.InaccessibleObjectException;

public class EncapsulationDemo {
    public static void main(String[] args) {
        try {
            Class<?> unsafeClass = Class.forName("sun.misc.Unsafe");
            Field field = unsafeClass.getDeclaredField("theUnsafe");

            field.setAccessible(true);

            System.out.println("Falha de segurança: acesso interno liberado!");
        } catch (InaccessibleObjectException e) {
            System.out.println("Sucesso de Arquitetura: JDK bloqueou acesso interno.");
            System.out.println(e.getMessage());
        } catch (Exception e) {
            System.out.println("Erro capturado: " + e.getClass().getSimpleName());
            System.out.println(e.getMessage());
        }
    }
}
EOF

javac EncapsulationDemo.java
java EncapsulationDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17