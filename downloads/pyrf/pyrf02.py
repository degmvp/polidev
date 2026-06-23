
# 02 - Lookahead e Lookbehind (Zero-width assertions)
def find_passwords_secure(text: str) -> List[str]:
    """Encontra senhas fortes usando positive lookahead"""
    # Senha com pelo menos 8 chars, letra maiúscula, minúscula e número
    pattern = r'(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}'
    return re.findall(pattern, text)