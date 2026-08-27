# POLYDEV | Python Professional Functions
# 05 - Funções com tipos genéricos e tipagem avançada
#
# Finalidade:
# Aumentar a robustez e manutenção do código usando tipagem estática e genérica em sistemas complexos.

from typing import TypeVar, Callable

T = TypeVar('T')

def apply_twice(func: Callable[[T], T], val: T) -> T:
    return func(func(val))

print(apply_twice(lambda x: x * 2, 5))  # Saída: 20
