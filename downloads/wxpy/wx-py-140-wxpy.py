# POLYDEV | Python Professional Functions
# 11 - Função para autenticação segura com hash e salt
#
# Finalidade:
# Proteger credenciais de usuários em sistemas.

import hashlib
import hmac
import os

def gerar_hash_senha(senha):
    """
    Gera hash seguro com salt usando PBKDF2-HMAC-SHA256.
    Retorna salt + hash em bytes.
    """
    salt = os.urandom(16)
    hash_senha = hashlib.pbkdf2_hmac("sha256", senha.encode(), salt, 100000)
    return salt + hash_senha


def verificar_senha(senha, hash_salvo):
    """
    Valida a senha usando comparação segura contra timing attacks.
    """
    salt = hash_salvo[:16]
    hash_original = hash_salvo[16:]
    hash_verificacao = hashlib.pbkdf2_hmac("sha256", senha.encode(), salt, 100000)
    return hmac.compare_digest(hash_verificacao, hash_original)


hash_armazenado = gerar_hash_senha("senha123")
print(verificar_senha("senha123", hash_armazenado))
