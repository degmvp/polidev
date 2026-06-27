#!/bin/bash
# ==========================================================
# POLYDEV | Java 17 Engineering
# JV17_05 - Text Blocks (Strings Multilinha)
# ==========================================================
#
# TECNOLOGIA:
# Java 17 (OpenJDK 17+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Permitir a criação de strings com múltiplas linhas sem a
# necessidade de quebras de linha explícitas (\n) ou
# concatenações cansativas com o sinal de '+'.
#
# ATENÇÃO:
# Usa-se aspas triplas duplas ("""). O conteúdo preserva a
# indentação visual do código fonte, mas o compilador
# remove a indentação à esquerda automaticamente.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv17 && cd polydev_jv17

cat > TextBlockDemo.java << 'EOF'
public class TextBlockDemo {
    public static void main(String[] args) {
        // Em vez de: String json = "{\n  \"user\": \"polydev\",\n  \"status\": \"active\"\n};"
        
        // Java 17: Text Block limpo e legível
        String json = """
                {
                  "user": "polydev",
                  "status": "active",
                  "system": "kali"
                }
                """;
        
        System.out.println("JSON gerado de forma limpa:");
        System.out.println(json);
        
        System.out.println("---");
        
        // Também excelente para queries SQL complexas
        String query = """
                SELECT u.name, r.role 
                FROM users u 
                JOIN roles r ON u.id = r.user_id 
                WHERE u.status = 'ACTIVE'
                """;
                
        System.out.println("Query SQL formatada:");
        System.out.println(query);
    }
}
EOF

javac TextBlockDemo.java
java TextBlockDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv17