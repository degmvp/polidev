# POLYDEV | Python Professional Functions
# 01 - Decoradores com parâmetros
#
# Finalidade:
# Modificar ou estender o comportamento de funções/métodos de forma flexível, especialmente útil em frameworks e sistemas distribuídos.

def log(level):
    def decorator(func):
        def wrapper(*args, **kwargs):
            print(f"[{level}] Executando {func.__name__}")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@log("DEBUG")
def process_data(data):
    return data.upper()

print(process_data("entrada"))
