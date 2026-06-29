JV21_04 - String Templates

Descrição: (Feature Preview - requer --enable-preview). Finaliza a falta de interpolação de strings no Java. Em vez de usar concatenação ("Olá " + nome + "!") ou String.format, você usa o String Template. Além da sintaxe limpa (\{variavel}), ele possui Processadores (Templates) que validam a string em tempo de compilação, evitando ataques críticos como Injeção de SQL.

public class StringTemplatesExample {
    public static void main(String[] args) {
        String name = "Java 21";
        int version = 21;

        // Template simples (usando o processador padrão STR)
        String message = STR."Bem-vindo ao \{name}, versão \{version}!";
        System.out.println(message);

        // Exemplo de segurança com SQL (conceito)
        // String query = SQL."SELECT * FROM users WHERE id = \{userId}";
        // Se userId for "1 OR 1=1", o processador SQL lança erro de compilação!
    }
}