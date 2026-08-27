# POLYDEV | Python Professional Functions
# 04 - Funções assíncronas (async def)
#
# Finalidade:
# Manipulação eficiente de operações de I/O, multitarefa em sistemas web, microserviços ou processamento paralelo não bloqueante.

import asyncio

async def fetch_data():
    await asyncio.sleep(2)
    return "Dados recebidos"

async def main():
    data = await fetch_data()
    print(data)

asyncio.run(main())
