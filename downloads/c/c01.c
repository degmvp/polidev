#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 01 - Leitura de Arquivos CSV
// ============================================

// 1 - Lê linha de CSV e separa campos por vírgula
int ler_csv_campo(FILE *fp, char *campos[], int max_campos) {
    char linha[1024];
    if (fgets(linha, 1024, fp) == NULL) return 0;
    
    int i = 0, campo = 0;
    campos[campo] = strtok(linha, ",");
    while (campos[campo] && campo < max_campos - 1) {
        campos[++campo] = strtok(NULL, ",\n");
    }
    return campo + 1;
}

// Exemplo 1: Lê dados de alunos CSV
int main1() {
    FILE *fp = fopen("alunos.csv", "w");
    fprintf(fp, "nome,idade,nota\nJoao,25,8.5\nMaria,22,9.2\n");
    fclose(fp);
    
    fp = fopen("alunos.csv", "r");
    char *campos[10];
    int n = ler_csv_campo(fp, campos, 10);
    printf("Ex1: %s tem %s anos, nota %s\n", campos[0], campos[1], campos[2]);
    fclose(fp);
    remove("alunos.csv");
    return 0;
}

// Exemplo 2: Processa vendas CSV
int main2() {
    FILE *fp = fopen("vendas.csv", "w");
    fprintf(fp, "produto,preco,qtd\nCaneta,2.50,100\nLapis,1.20,150\n");
    fclose(fp);
    
    fp = fopen("vendas.csv", "r");
    char *campos[10];
    double total = 0;
    while (ler_csv_campo(fp, campos, 10) > 0) {
        double preco = atof(campos[1]);
        int qtd = atoi(campos[2]);
        total += preco * qtd;
    }
    printf("Ex2: Total vendas: R$%.2f\n", total);
    fclose(fp);
    remove("vendas.csv");
    return 0;
}

// Exemplo 3: Lê config CSV
int main3() {
    FILE *fp = fopen("config.csv", "w");
    fprintf(fp, "cor,tamanho,ativo\nazul,grande,1\n");
    fclose(fp);
    
    fp = fopen("config.csv", "r");
    char *campos[10];
    ler_csv_campo(fp, campos, 10);
    printf("Ex3: Cor=%s, Tamanho=%s, Ativo=%s\n", 
           campos[0], campos[1], campos[2]);
    fclose(fp);
    remove("config.csv");
    return 0;
}