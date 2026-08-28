#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 09 - Menu Interativo
// ============================================

void mostrar_menu() {
    printf("\n=== MENU CALCULADORA ===\n");
    printf("1 - Somar\n2 - Subtrair\n3 - Sair\n");
    printf("Opcao: ");
}

int main1() {
    int opcao;
    do {
        mostrar_menu();
        scanf("%d", &opcao);
        if (opcao == 1) {
            int a, b; printf("Digite 2 nums: "); scanf("%d%d", &a, &b);
            printf("Soma: %d\n", a + b);
        }
    } while (opcao != 3);
    return 0;
}

int main2() {
    int op, a = 10, b = 5;
    mostrar_menu(); scanf("%d", &op);
    switch(op) {
        case 1: printf("Soma %d\n", a + b); break;
        case 2: printf("Sub %d\n", a - b); break;
        default: printf("Invalido\n");
    }
    return 0;
}

int main3() {
    printf("Simulando 3 execucoes:\n");
    printf("Exec1: Op1 -> 15\n");
    printf("Exec2: Op2 -> 5\n");
    printf("Exec3: Op3 -> Sai\n");
    return 0;
}