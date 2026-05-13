#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>

// ============================================
// C 10 - Gerador Números Aleatórios
// ============================================

int numero_aleatorio(int min, int max) {
    return min + rand() % (max - min + 1);
}

void preencher_aleatorio(int arr[], int n, int min, int max) {
    for (int i = 0; i < n; i++) {
        arr[i] = numero_aleatorio(min, max);
    }
}

int main1() {
    srand(time(NULL));
    printf("Aleatorios 1-100: ");
    for (int i = 0; i < 10; i++) {
        printf("%d ", numero_aleatorio(1, 100));
    }
    printf("\n");
    return 0;
}

int main2() {
    int arr[5];
    preencher_aleatorio(arr, 5, 10, 50);
    printf("Array aleatorio: ");
    for (int i = 0; i < 5; i++) printf("%d ", arr[i]);
    printf("\n");
    return 0;
}

int main3() {
    srand(123); // Semente fixa para teste
    printf("Reprodutivel: ");
    for (int i = 0; i < 5; i++) printf("%d ", numero_aleatorio(1, 10));
    return 0;
}