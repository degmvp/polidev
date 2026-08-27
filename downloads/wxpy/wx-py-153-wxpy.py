# 10 - Performance: re.compile + finditer (melhor prática)
class LogAnalyzer:
    """Classe otimizada para análise massiva de logs"""
    
    def __init__(self):
        self.error_pattern = re.compile(
            r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}).*?ERROR.*?(\w+Error)',
            re.IGNORECASE
        )
    
    def find_errors(self, log_content: str) -> List[Dict]:
        results = []
        for match in self.error_pattern.finditer(log_content):
            results.append({
                'date': match.group(1),
                'time': match.group(2),
                'error_type': match.group(3)
            })
        return results