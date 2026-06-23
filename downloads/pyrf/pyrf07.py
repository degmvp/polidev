
# 07 - Conditional Regex (avançado)
def validate_strong_password(password: str) -> bool:
    """Validação complexa com regex condicional"""
    pattern = re.compile(r'''
        ^(?=.*[A-Z])                # deve ter letra maiúscula
        (?=.*[a-z])                 # deve ter letra minúscula
        (?=.*\d)                    # deve ter número
        (?=.*[@$!%*?&])?            # pode ter caractere especial
        [A-Za-z\d@$!%*?&]{10,}$     # mínimo 10 caracteres
    ''', re.VERBOSE)
    return bool(pattern.match(password))