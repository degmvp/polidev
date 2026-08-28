// wx-cp-040-wxcp.cpp
// Migrado do acervo legado: cppb01.cpp
// POLYDEV | WXCP
// Título: Controle de permissões com flags bitwise

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

enum Permission{READ=0,WRITE=1,EXEC=2};
std::uint32_t grantPermission(std::uint32_t f,Permission p){return setBit(f,p);} bool hasPermission(std::uint32_t f,Permission p){return isBitSet(f,p);} 
int main(){std::uint32_t user=0; user=grantPermission(user,READ); user=grantPermission(user,WRITE); std::cout<<"Leitura? "<<hasPermission(user,READ)<<" Execução? "<<hasPermission(user,EXEC)<<'\n';}
