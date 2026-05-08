17. Template com parâmetro auto (C++17)
cpp17.cpp
// Função template que aceita qualquer tipo não-tipo
template <auto N>
void mostrarConstante() {
    std::cout << N << '
';
}
// Uso: mostrarConstante<42>();