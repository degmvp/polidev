1. Controle de permissões de usuário

#include <iostream>

enum Permission {
    READ  = 0,
    WRITE = 1,
    EXEC  = 2
};

uint32_t grantPermission(uint32_t userFlags, Permission p) {
    return setBit(userFlags, p);
}

bool hasPermission(uint32_t userFlags, Permission p) {
    return isBitSet(userFlags, p);
}

int main() {
    uint32_t user = 0;
    user = grantPermission(user, READ);
    user = grantPermission(user, WRITE);

    std::cout << "Permissão de leitura? " << hasPermission(user, READ) << "\n";
    std::cout << "Permissão de execução? " << hasPermission(user, EXEC) << "\n";
}