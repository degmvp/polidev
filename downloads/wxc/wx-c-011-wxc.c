#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 11 - Contador Caracteres/Palavras
// ============================================

int contar_palavras(char *str) {
    int count = 0;
    char *p = strtok(str, " ");
    while (p) { count++; p = strtok(NULL, " "); }
    return count;
}

int contar_vogais(char *str) {
    int count = 0;
    for (int i = 0; str[i]; i++) {
        char c = tolower(str[i]);
        if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') count++;
    }
    return count;
}

int main1() {
    char texto[] = "Ola mundo programacao";
    printf("Palavras: %d\n", contar_palavras(texto));
    printf("Vogais: %d\n", contar_vogais(texto));
    return 0;
}

int main2() {
    printf("Texto 'C eh facil': %d palavras, %d vogais\n", 
           contar_palavras("C eh facil"), contar_vogais("C eh facil"));
    return 0;
}

int main3() {
    char frases[][50] = {"abc", "aeiou", "xyz"};
    for (int i = 0; i < 3; i++) {
        printf("%s: %d vogais\n", frases[i], contar_vogais(frases[i]));
    }
    return 0;
}