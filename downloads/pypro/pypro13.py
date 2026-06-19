# POLYDEV | Python Professional Functions
# 13 - Função para controle de concorrência com lock em threads
#
# Finalidade:
# Evitar condições de corrida em sistemas multi-threaded.

import threading

lock = threading.Lock()
contador = 0

def incrementar():
    global contador
    with lock:
        temp = contador
        temp += 1
        contador = temp

threads = [threading.Thread(target=incrementar) for _ in range(1000)]
[t.start() for t in threads]
[t.join() for t in threads]
print(contador)  # Deve ser 1000
