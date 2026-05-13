#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ============================================
// C 04 - Strings: Inverter + Palíndromo
// ============================================

// 11 - Inverte string no lugar
void inverter_string(char *str) {
    int len = strlen(str);
    for (int i = 0; i < len / 2; i++) {
        char temp = str[i];
        str[i] = str[len - 1 - i];
        str[len - 1 - i] = temp;
    }
}

// 15 - Palíndromo ignorando case/não alfanum
int eh_palindromo(char *str) {
    int left = 0, right = strlen(str) - 1;
    while (left < right) {
        while (left < right && !isalnum(str[left])) left++;
        while (left < right && !isalnum(str[right])) right--;
        if (tolower(str[left++]) != tolower(str[right--])) return 0;
    }
    return 1;
}

int main1() {
    char s1[] = "radar";
    printf("Palindromo '%s': %s\n", s1, eh_palindromo(s1) ? "SIM" : "NAO");
    
    char s2[] = "abc";
    inverter_string(s2);
    printf("Inverte 'abc': %s\n", s2);
    return 0;
}

int main2() {
    printf("Palindromo 'A man a plan a canal Panama': %s\n", 
           eh_palindromo("A man a plan a canal Panama") ? "SIM" : "NAO");
    
    char s3[] = "hello";
    inverter_string(s3);
    printf("Inverte 'hello': %s\n", s3);
    return 0;
}

int main3() {
    char nomes[] = "ana bob eve";
    char *palavra = strtok(nomes, " ");
    while (palavra) {
        printf("%s palindromo? %s\n", palavra, 
               eh_palindromo(palavra) ? "SIM" : "NAO");
        palavra = strtok(NULL, " ");
    }
    return 0;
}