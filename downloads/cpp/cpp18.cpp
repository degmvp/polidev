18. Fold expressions (C++17)
cpp18.cpp
// Soma de vários argumentos
template <typename... Args>
auto soma(Args... args) {
    return (args + ...);
}
// std::cout << soma(1,2,3,4); // 10