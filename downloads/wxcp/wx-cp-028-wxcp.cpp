// wx-cp-028-wxcp.cpp
// Migrado do acervo legado: cpp09.cpp
// POLYDEV | WXCP
// Título: Bitwise: definir, limpar, alternar e testar bits

#include <cstdint>
#include <iostream>
std::uint8_t setBit(std::uint8_t v,int b){return static_cast<std::uint8_t>(v | (1u<<b));}
std::uint8_t clearBit(std::uint8_t v,int b){return static_cast<std::uint8_t>(v & ~(1u<<b));}
std::uint8_t toggleBit(std::uint8_t v,int b){return static_cast<std::uint8_t>(v ^ (1u<<b));}
bool testBit(std::uint8_t v,int b){return (v & (1u<<b))!=0;}
int main(){std::uint8_t v=0; v=setBit(v,2); std::cout<<int(v)<<' '<<testBit(v,2)<<' '; v=toggleBit(v,2); std::cout<<int(v)<<' '; v=setBit(v,3); v=clearBit(v,3); std::cout<<int(v)<<'\n';}
