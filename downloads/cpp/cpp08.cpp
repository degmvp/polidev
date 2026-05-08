8. Bitwise: encontrar elemento único em array (XOR)
cpp08.cpp
// Todos os outros aparecem duas vezes
int unico(const std::vector<int>& v) {
    int res = 0;
    for (int x : v) res ^= x;
    return res;
}