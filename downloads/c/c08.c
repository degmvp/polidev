#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 08 - Calculadora Simples
// ============================================

int somar(int a, int b) { return a + b; }
int subtrair(int a, int b) { return a - b; }
int multiplicar(int a, int b) { return a * b; }
int dividir(int a, int b) { 
    if (b == 0) return 0; 
    return a / b; 
}

int main1() {
    printf("10 + 5 = %d\n", somar(10, 5));
    printf("10 - 5 = %d\n", subtrair(10, 5));
    printf("10 * 5 = %d\n", multiplicar(10, 5));
    printf("10 / 2 = %d\n", dividir(10, 2));
    return 0;
}

int main2() {
    int a = 25, b = 4;
    printf("25/4=%d (resto %d)\n", dividir(a,b), a % b);
    printf("Operações: +-%c * / \n", '*');
    return 0;
}

int main3() {
    printf("Teste overflow: %d * %d = %d\n", 10000, 10000, multiplicar(10000, 10000));
    return 0;
}