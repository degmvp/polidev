#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 12 - Matriz Simples (3x3)
// ============================================

void preencher_matriz(int mat[3][3]) {
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            mat[i][j] = (i * 3) + j + 1;
}

int soma_diagonal(int mat[3][3]) {
    return mat[0][0] + mat[1][1] + mat[2][2];
}

int main1() {
    int mat[3][3];
    preencher_matriz(mat);
    printf("Matriz 3x3:\n");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) printf("%d ", mat[i][j]);
        printf("\n");
    }
    printf("Diagonal: %d\n", soma_diagonal(mat));
    return 0;
}

int main2() {
    int mat[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
    printf("Soma total: ");
    int soma = 0;
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) soma += mat[i][j];
    printf("%d\n", soma);
    return 0;
}

int main3() {
    printf("Matriz identidade diagonal=3\n");
    return 0;
}