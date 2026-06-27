#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_01 - Sealed Classes (Controle Rígido de Herança)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Restringir quais classes podem herdar de uma superclasse.
# No Rust, enums com dados fazem isso nativamente. No Java 17,
# o 'sealed' traz essa segurança em tempo de compilação para
# a hierarquia de classes, impedindo extensões indevidas.
#
# ATENÇÃO:
# Classes seladas devem estar no mesmo pacote ou no mesmo
# módulo. Usa-se 'permits' para listar EXATAMENTE quem pode
# herdar da classe mãe.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > Shape.java << 'EOF'
// A palavra 'sealed' define que apenas Circle e Rectangle podem herdar de Shape
public sealed class Shape permits Circle, Rectangle {}
EOF

cat > Circle.java << 'EOF'
// 'final' impede que Circle seja herdado por outra classe
public final class Circle extends Shape {
    double radius;
    public Circle(double radius) { this.radius = radius; }
}
EOF

cat > Rectangle.java << 'EOF'
// 'non-sealed' permite que Rectangle seja aberto para herança novamente, se necessário
public non-sealed Rectangle extends Shape {
    double width, height;
    public Rectangle(double w, double h) { this.width = w; this.height = h; }
}
EOF

cat > SealedDemo.java << 'EOF'
public class SealedDemo {
    public static void main(String[] args) {
        Shape c = new Circle(5.0);
        Shape r = new Rectangle(10.0, 2.0);
        
        System.out.println("Circle instanciado: " + (c instanceof Circle));
        System.out.println("Rectangle instanciado: " + (r instanceof Rectangle));
    }
}
EOF

javac *.java
java SealedDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17