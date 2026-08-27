# 04 - Regex com Flags Avançadas + Verbose
def parse_log_line(log: str) -> Optional[Dict]:
    """Parser profissional de logs usando re.VERBOSE"""
    pattern = re.compile(r'''
        (?P<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})  # data e hora
        \s+\[(?P<level>\w+)\]                               # nível
        \s+(?P<module>[\w\.]+):                             # módulo
        \s+(?P<message>.*)                                  # mensagem
    ''', re.VERBOSE)
    match = pattern.search(log)
    return match.groupdict() if match else None