#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 14 - Arquivo Texto Básico
// ============================================

void escrever_arquivo(char *nome, char *conteudo) {
    FILE *fp = fopen(nome, "w");
    fprintf(fp, "%s", conteudo);
    fclose(fp);
}

int ler_arquivo(char *nome, char *buffer, int tam) {
    FILE *fp = fopen(nome, "r");
    if (!fp) return 0;
    fgets(buffer, tam, fp);
    fclose(fp);
    return 1;
}

int main1() {
    escrever_arquivo("teste.txt", "Linha 1\nLinha 2");
    char buf[100];
    if (ler_arquivo("teste.txt", buf, 100)) printf("Lido: %s", buf);
    remove("teste.txt");
    return 0;
}

int main2() {
    FILE *fp = fopen("log.txt", "a");
    fprintf(fp, "Log %s\n", "2026-05-13");
    fclose(fp);
    char buf[100]; ler_arquivo("log.txt", buf, 100);
    printf("Log: %s", buf);
    remove("log.txt");
    return 0;
}

int main3() {
    printf("Arquivo binario exemplo:\n");
    FILE *fp = fopen("dados.bin", "wb");
    int x = 12345;
    fwrite(&x, sizeof(int), 1, fp);
    fclose(fp);
    return 0;
}