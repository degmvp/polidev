#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 07 - Validação Email Básica
// ============================================

// Valida email simples (contém @ e .)
int validar_email(char *email) {
    if (!strchr(email, '@') || !strchr(email, '.')) return 0;
    if (strchr(email, ' ') || strlen(email) < 5) return 0;
    return 1;
}

// Conta emails válidos em lista
int contar_emails_validos(char *lista) {
    int count = 0;
    char *email = strtok(lista, ";");
    while (email) {
        if (validar_email(email)) count++;
        email = strtok(NULL, ";");
    }
    return count;
}

int main1() {
    printf("joao@email.com: %s\n", validar_email("joao@email.com") ? "VALIDO" : "INVALIDO");
    printf("maria@gmail: %s\n", validar_email("maria@gmail") ? "VALIDO" : "INVALIDO");
    printf("teste: %s\n", validar_email("teste") ? "VALIDO" : "INVALIDO");
    return 0;
}

int main2() {
    char lista[] = "joao@email.com;maria@gmail.com;teste@inválido;ana@exemplo.br";
    printf("Emails validos: %d\n", contar_emails_validos(lista));
    return 0;
}

int main3() {
    char emails[][50] = {"user@dominio.com", "nao@temponto", "ok@ok.br"};
    for (int i = 0; i < 3; i++) {
        printf("%s: %s\n", emails[i], validar_email(emails[i]) ? "OK" : "ERRO");
    }
    return 0;
}