# POLYDEV | Python Professional Functions
# 07 - Função para realizar consulta otimizada em banco de dados com cache em memória
#
# Finalidade:
# Evitar consultas repetidas a banco, melhorando desempenho.

cache_consultas = {}

def consulta_banco_cache(query, executor):
    if query in cache_consultas:
        return cache_consultas[query]
    resultado = executor(query)
    cache_consultas[query] = resultado
    return resultado

def executor_simulado(q):
    # Simula execução de query no banco
    return {"dados": "resultado da " + q}

resultado1 = consulta_banco_cache("SELECT * FROM tabela", executor_simulado)
resultado2 = consulta_banco_cache("SELECT * FROM tabela", executor_simulado)  # Retorna cache
