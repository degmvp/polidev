JV21_06 - Record Patterns

Descrição: Permite a "desconstrução" (destructuring) de um Record diretamente dentro de expressões instanceof ou switch. Em vez de pegar o objeto inteiro e chamar os métodos acessores (record.x()), você extrai as variáveis internas em uma única linha, tornando o código muito mais limpo.

public class RecordPatternsExample {
    public record Point(int x, int y) {}

    public static void main(String[] args) {
        Object obj = new Point(10, 20);

        // Antes: if (obj instanceof Point p) { int x = p.x(); int y = p.y(); ... }
        // Agora (Desconstrução direta):
        if (obj instanceof Point(int x, int y)) {
            System.out.println("X: " + x + ", Y: " + y);
        }
    }
}