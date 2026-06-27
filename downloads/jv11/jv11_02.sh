#!/bin/bash
# ==========================================================
# POLYDEV | Java 11 Engineering
# JV11_02 - Novo HTTP Client Nativo (HTTP/2 e WebSockets)
# ==========================================================
#
# TECNOLOGIA:
# Java 11 (OpenJDK 11+)
#
# LINGUAGEM:
# Java / Bash
#
# OBJETIVO:
# Substituir o velho e verboso HttpUrlConnection por um
# cliente moderno, fluente e nativo, com suporte completo
# a HTTP/2 e APIs assíncronas sem necessidade de libs externas.
#
# ATENÇÃO:
# O HttpClient fica no pacote java.net.http. Requer
# inicialização via Builder e suporta requisições síncronas (send)
# e assíncronas (sendAsync).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_jv11 && cd polydev_jv11

cat > HttpDemo.java << 'EOF'
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class HttpDemo {
    public static void main(String[] args) throws Exception {
        // 1. Cria o cliente HTTP (Suporta HTTP/2 nativamente)
        HttpClient client = HttpClient.newHttpClient();

        // 2. Constrói a requisição de forma fluente (Builder Pattern)
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://httpbin.org/get"))
                .header("Accept", "application/json")
                .header("X-Polydev-Header", "SecurityAudit")
                .GET()
                .build();

        // 3. Envia de forma síncrona e extrai o corpo como String
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Protocolo Negociado: " + response.version());
        System.out.println("Corpo da Resposta:\n" + response.body());
    }
}
EOF

javac HttpDemo.java
java HttpDemo

rm -f *.class *.java && cd .. && rmdir polydev_jv11