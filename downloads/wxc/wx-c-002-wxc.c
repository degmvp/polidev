#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 02 - Conversão Decimal/Binário + Bitwise
// ============================================

// 2 - Converte decimal para binário (imprime)
void decimal_para_binario(int num) {
    if (num == 0) { printf("0"); return; }
    decimal_para_binario(num / 2);
    printf("%d", num % 2);
}

// 3 - Bitwise AND
int bitwise_and(int a, int b) { return a & b; }

// 4 - Bitwise OR  
int bitwise_or(int a, int b) { return a | b; }

// 5 - Bitwise XOR
int bitwise_xor(int a, int b) { return a ^ b; }

// 6 - Bitwise NOT
int bitwise_not(int a) { return ~a; }

// 7 - Shift esquerdo
int shift_left(int a, int n) { return a << n; }

// 8 - Shift direito
int shift_right(int a, int n) { return a >> n; }

int main1() {
    printf("Decimal 13 binario: "); decimal_para_binario(13); printf("\n");
    printf("12 & 10 = %d (1100 & 1010)\n", bitwise_and(12, 10));
    printf("12 | 10 = %d (1100 | 1010)\n", bitwise_or(12, 10));
    return 0;
}

int main2() {
    printf("12 ^ 10 = %d (toggle bits)\n", bitwise_xor(12, 10));
    printf("~12 = %d (inverte bits)\n", bitwise_not(12));
    printf("5 << 3 = %d (x8)\n", shift_left(5, 3));
    printf("40 >> 2 = %d (/4)\n", shift_right(40, 2));
    return 0;
}

int main3() {
    int flags = 0; // 000
    flags = bitwise_or(flags, 1);  // Flag1 ativa: 001
    flags = bitwise_or(flags, 4);  // Flag3 ativa: 101
    printf("Flags ativas: %d (Flag1+Flag3)\n", flags);
    if (flags & 1) printf("Flag1 OK\n");
    return 0;
}