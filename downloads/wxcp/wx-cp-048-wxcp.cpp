// wx-cp-048-wxcp.cpp
// Migrado do acervo legado: cppb09.cpp
// POLYDEV | WXCP
// Título: Auditoria do menor bit ativo

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

void auditLowestFlag(std::uint32_t f){std::cout<<"Menor flag ativa: "<<lowestBit(f)<<'\n';} int main(){auditLowestFlag(0b101100u);}
