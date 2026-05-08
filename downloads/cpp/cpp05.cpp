5. Bitwise: verificar se número é potência de 2
cpp05.cpp
// n > 0 e (n & (n-1)) == 0
bool ehPotenciaDe2(int n) {
    return n > 0 && (n & (n - 1)) == 0;
}