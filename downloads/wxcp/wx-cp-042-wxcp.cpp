// wx-cp-042-wxcp.cpp
// Migrado do acervo legado: cppb03.cpp
// POLYDEV | WXCP
// Título: Compressão de flags de transação

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

std::uint32_t compressFlags(bool approved,bool fraud,bool priority){std::uint32_t f=0; if(approved)f=setBit(f,0); if(fraud)f=setBit(f,1); if(priority)f=setBit(f,2); return f;} int main(){std::cout<<"Flags: "<<compressFlags(true,false,true)<<'\n';}
