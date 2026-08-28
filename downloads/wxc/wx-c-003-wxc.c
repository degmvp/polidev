#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 03 - Números Primos + Fatorial
// ============================================

// 9 - Verifica primo otimizado
int eh_primo(int n) {
    if (n <= 1) return 0;
    if (n <= 3) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return 0;
    }
    return 1;
}

// 10 - Fatorial iterativo (evita overflow recursão)
long long fatorial(int n) {
    long long fat = 1;
    for (int i = 2; i <= n; i++) fat *= i;
    return fat;
}

int main1() {
    printf("Primos 1-20: ");
    for (int i = 1; i <= 20; i++) {
        if (eh_primo(i)) printf("%d ", i);
    }
    printf("\nFatorial 6 = %lld\n", fatorial(6));
    return 0;
}

int main2() {
    printf("17 primo? %s\n", eh_primo(17) ? "SIM" : "NAO");
    printf("15 primo? %s\n", eh_primo(15) ? "SIM" : "NAO");
    printf("Fatorial 0 = %lld\n", fatorial(0));
    return 0;
}

int main3() {
    printf("Fatorial 10 = %lld\n", fatorial(10));
    int count = 0;
    for (int i = 100; i < 200; i++) count += eh_primo(i);
    printf("Primos 100-199: %d\n", count);
    return 0;
}