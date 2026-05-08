7. Bitwise: trocar dois números sem variável auxiliar
cpp07.cpp
// Usando XOR
void trocar(int& a, int& b) {
    a ^= b;
    b ^= a;
    a ^= b;
}