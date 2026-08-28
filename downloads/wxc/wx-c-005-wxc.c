#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 05 - Arrays: Bubble Sort + Busca Binária
// ============================================

// 12 - Bubble Sort simples
void bubble_sort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++)
        for (int j = 0; j < n - i - 1; j++)
            if (arr[j] > arr[j + 1]) {
                int temp = arr[j]; arr[j] = arr[j + 1]; arr[j + 1] = temp;
            }
}

// 13 - Busca binária (array ordenado)
int busca_binaria(int arr[], int n, int x) {
    int left = 0, right = n - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == x) return mid;
        if (arr[mid] < x) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

int main1() {
    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = 7;
    
    bubble_sort(arr, n);
    printf("Ordenado: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    
    printf("\nBusca 22: pos %d\n", busca_binaria(arr, n, 22));
    return 0;
}

int main2() {
    int notas[] = {10, 20, 30, 40, 50, 60};
    printf("Busca 40: %d\n", busca_binaria(notas, 6, 40));
    printf("Busca 99: %d\n", busca_binaria(notas, 6, 99));
    return 0;
}

int main3() {
    int vendas[] = {100, 200, 300, 400, 500};
    bubble_sort(vendas, 5);
    printf("Vendas ordenadas: ");
    for (int i = 0; i < 5; i++) printf("%d ", vendas[i]);
    printf("\nPosicao 300: %d\n", busca_binaria(vendas, 5, 300));
    return 0;
}