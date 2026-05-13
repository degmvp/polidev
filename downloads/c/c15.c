#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 15 - Data/Hora Simples
// ============================================

struct Data {
    int dia, mes, ano;
};

int dias_mes(int mes, int ano) {
    int dias[] = {31,28,31,30,31,30,31,31,30,31,30,31};
    if (mes == 2 && (ano % 4 == 0)) return 29;
    return dias[mes - 1];
}

void formatar_data(struct Data d, char *str) {
    sprintf(str, "%02d/%02d/%d", d.dia, d.mes, d.ano);
}

int main1() {
    struct Data hoje = {13, 5, 2026};
    char data_str[20];
    formatar_data(hoje, data_str);
    printf("Data: %s\n", data_str);
    printf("Dias maio: %d\n", dias_mes(5, 2026));
    return 0;
}

int main2() {
    printf("Bisexto 2024? %s\n", (2024 % 4 == 0) ? "SIM" : "NAO");
    printf("Dias fev 2024: %d\n", dias_mes(2, 2024));
    return 0;
}

int main3() {
    struct Data datas[] = {{1,1,2026}, {29,2,2024}, {31,12,2025}};
    for (int i = 0; i < 3; i++) {
        char str[20]; formatar_data(datas[i], str);
        printf("%s\n", str);
    }
    return 0;
}