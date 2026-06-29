JV21_07 - Pattern Matching for switch (Final)

Descrição: Transforma o switch tradicional em uma ferramenta poderosa de pattern matching. Você pode fazer o matching diretamente por tipo, lidar com null de forma segura, usar guardas (condições extras com when) e garantir que Sealed Classes sejam tratadas de forma exaustiva (o compilador avisa se faltar algum case).

public class SwitchPatternMatchingExample {
    sealed interface Shape permits Circle, Rectangle {}
    record Circle(double radius) implements Shape {}
    record Rectangle(double width, double height) implements Shape {}

    public static void main(String[] args) {
        Shape shape = new Circle(5.0);

        // Switch moderno com Pattern Matching, Guardas e Null check
        switch (shape) {
            case Circle(var r) when r > 10.0 -> System.out.println("Círculo Grande");
            case Circle(var r) -> System.out.println("Círculo com raio: " + r);
            case Rectangle(var w, var h) -> System.out.println("Retângulo " + w + "x" + h);
            case null -> System.out.println("Forma nula!");
            // Não precisa de default, pois Shape é sealed e todos os filhos foram cobertos
        }
    }
}