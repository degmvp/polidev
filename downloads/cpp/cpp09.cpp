9. Bitwise: definir/limpar/alternar um bit
cpp09.cpp
// Operações em um byte
uint8_t setBit(uint8_t valor, int bit) { return valor | (1 << bit); }
uint8_t clearBit(uint8_t valor, int bit) { return valor & ~(1 << bit); }
uint8_t toggleBit(uint8_t valor, int bit) { return valor ^ (1 << bit); }
bool testBit(uint8_t valor, int bit) { return valor & (1 << bit); }