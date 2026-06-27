#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_02 - Records (O Fim do Boilerplate)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Eliminar a necessidade de criar Getters, Setters, ToString,
# Equals e HashCode para simples transportes de dados (DTOs).
# Um Record é imutável por padrão e define tudo em uma linha.
#
# ATENÇÃO:
# Records não substituem entidades de banco de dados que
# precisam de mutabilidade (JPA/Hibernate), mas são perfeitos
# para retornos de API e mensageria (Kafka/RabbitMQ).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > UserRecord.java << 'EOF'
// Em uma linha, o Java gera: Construtor, Getters (user(), email()), toString, equals e hashCode
public record UserRecord(String user, String email) {}
EOF

cat > RecordDemo.java << 'EOF'
public class RecordDemo {
    public static void main(String[] args) {
        // Instanciação limpa e direta
        UserRecord admin = new UserRecord("polydev", "admin@polydev.com");
        
        // O toString é gerado automaticamente pelo compilador
        System.out.println("Dados do Registro: " + admin);
        
        // Acesso imutável (não existe setAdmin(). Se precisar mudar, cria-se um novo objeto)
        System.out.println("Usuário: " + admin.user());
        System.out.println("Email: " + admin.email());
    }
}
EOF

javac *.java
java RecordDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17