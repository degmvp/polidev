# POLYDEV | Python Professional Functions
# 12 - Função para envio assíncrono de emails usando asyncio
#
# Finalidade:
# Manter a responsividade do sistema enquanto realiza tarefas de I/O.

import asyncio

async def enviar_email_async(remetente, destino, mensagem):
    """
    Estrutura assíncrona para envio de e-mail.
    Em produção, use biblioteca SMTP assíncrona ou fila de mensagens.
    """
    await asyncio.sleep(0)
    print(f"Email enviado de {remetente} para {destino}: {mensagem}")


asyncio.run(enviar_email_async("meuemail@empresa.com", "usuario@cliente.com", "Olá!"))
