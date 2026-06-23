
# 03 - Substituição Avançada com Função
def anonymize_emails(text: str) -> str:
    """Anonymiza emails mantendo o domínio"""
    def replace_email(match):
        email = match.group(0)
        user, domain = email.split('@')
        return f"***@{domain}"
    
    return re.sub(r'[\w\.-]+@[\w\.-]+', replace_email, text)