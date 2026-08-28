// wx-cp-029-wxcp.cpp
// Migrado do acervo legado: cpp10.cpp
// POLYDEV | WXCP
// Título: Lambda genérica com auto

#include <algorithm>
#include <iostream>
#include <vector>
int main(){std::vector<int> v{4,1,9,3}; auto maiorQue=[](const auto& a,const auto& b){return a>b;}; std::sort(v.begin(),v.end(),maiorQue); for(auto x:v) std::cout<<x<<' '; std::cout<<'\n';}
