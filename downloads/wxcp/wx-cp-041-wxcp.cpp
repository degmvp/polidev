// wx-cp-041-wxcp.cpp
// Migrado do acervo legado: cppb02.cpp
// POLYDEV | WXCP
// Título: Máscara bitwise para extrair código de agência

#include <bit>
#include <cstdint>
#include <iostream>
std::uint32_t setBit(std::uint32_t v,int b){return v | (1u<<b);}
bool isBitSet(std::uint32_t v,int b){return (v&(1u<<b))!=0;}
std::uint32_t toggleBit(std::uint32_t v,int b){return v^(1u<<b);}
int countBits(std::uint32_t v){return std::popcount(v);}
bool isPowerOfTwo(std::uint32_t v){return v>0 && (v&(v-1))==0;}
std::uint32_t lowestBit(std::uint32_t v){return v & (~v+1u);}
std::uint32_t rotateLeft(std::uint32_t v,int n){return std::rotl(v,n);}
std::uint32_t rotateRight(std::uint32_t v,int n){return std::rotr(v,n);}
std::uint32_t maskBits(std::uint32_t v,int start,int width){return (v>>start)&((1u<<width)-1u);}

std::uint32_t extractAgencyCode(std::uint32_t data){return maskBits(data,8,8);} int main(){std::uint32_t packed=0b1010101100110010; std::cout<<"Agência: "<<extractAgencyCode(packed)<<'\n';}
