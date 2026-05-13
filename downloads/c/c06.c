#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 06 - Matemática: MDC + Aplicações
// ============================================

// 14 - MDC Euclides recursivo
int mdc(int a, int b) {
    return b == 0 ? a : mdc(b, a % b);
}

// Exemplo: Simplifica fração
void simplificar_fracao(int num, int den, int *num_s, int *den_s) {
    int d = mdc(num, den);
    *num_s = num / d;
    *den_s = den / d;
}

int main1() {
    printf("MDC(48, 18) = %d\n", mdc(48, 18));
    printf("MDC(100, 25) = %d\n", mdc(100, 25));
    return 0;
}

int main2() {
    int n1 = 12, d1 = 18, n2, d2;
    simplificar_fracao(n1, d1, &n2, &d2);
    printf("12/18 simplifica para %d/%d\n", n2, d2);
    
    n1 = 56; d1 = 14;
    simplificar_fracao(n1, d1, &n2, &d2);
    printf("56/14 simplifica para %d/%d\n", n2, d2);
    return 0;
}

int main3() {
    int pares[] = {{36,24}, {45,60}, {1001,1001}};
    for (int i = 0; i < 3; i++) {
        printf("MDC(%d,%d)=%d\n", pares[i][0], pares[i][1], 
               mdc(pares[i][0], pares[i][1]));
    }
    return 0;
}