#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 13 - Struct Pessoa Simples
// ============================================

struct Pessoa {
    char nome[50];
    int idade;
    float salario;
};

void mostrar_pessoa(struct Pessoa p) {
    printf("%s, %d anos, R$%.2f\n", p.nome, p.idade, p.salario);
}

int main1() {
    struct Pessoa joao = {"Joao", 25, 2500.50};
    mostrar_pessoa(joao);
    return 0;
}

int main2() {
    struct Pessoa pessoas[3] = {
        {"Ana", 30, 3500},
        {"Carlos", 28, 2800},
        {"Beatriz", 32, 4200}
    };
    float media = 0;
    for (int i = 0; i < 3; i++) {
        mostrar_pessoa(pessoas[i]);
        media += pessoas[i].salario;
    }
    printf("Media salario: R$%.2f\n", media / 3);
    return 0;
}

int main3() {
    struct Pessoa *p = malloc(sizeof(struct Pessoa));
    strcpy(p->nome, "Novo");
    p->idade = 20;
    p->salario = 1800;
    mostrar_pessoa(*p);
    free(p);
    return 0;
}