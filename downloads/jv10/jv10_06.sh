#!/bin/bash
# ==========================================================
# POLYDEV | Java 10 Engineering
# JV10_06 - Certificados Raiz (Root CA Cacerts)
# ==========================================================
#
# TECNOLOGIA:
# Java 10 (OpenJDK 10+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Demonstrar que o Java 10 agora possui um keystore (cacerts)
# populated com certificados raiz da Autoridade Certificadora.
# Isso elimina o famoso SSLHandshakeException em chamadas HTTPS.
#
# ATENÇÃO:
# Antes do Java 10, era comum ter que importar certificados
# manualmente usando keytool para consumir APIs externas.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv10 && cd polydev_jv10

cat > HttpsDemo.java << 'EOF'
import java.net.URL;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class HttpsDemo {
    public static void main(String[] args) {
        try {
            // Tentativa de conexão HTTPS direta sem configurar keystore customizado
            URL url = new URL("https://www.google.com");
            BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream()));
            String linha;
            int linhas = 0;
            while ((linha = br.readLine()) != null) { linhas++; }
            br.close();
            System.out.println("[SUCESSO] Conexão HTTPS estabelecida. Linhas lidas: " + linhas);
        } catch (Exception e) {
            System.out.println("[FALHA] " + e.getMessage());
        }
    }
}
EOF

javac HttpsDemo.java
java HttpsDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv10