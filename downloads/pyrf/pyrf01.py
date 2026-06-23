import re
from typing import List, Dict, Optional

# 01 - Named Groups + Dict Extraction
def extract_named_groups(text: str) -> Dict:
    """Extrai dados usando named groups e retorna dicionário limpo"""
    pattern = r"(?P<nome>\w+)\s+(?P<idade>\d{1,3})\s+(?P<email>[\w\.-]+@[\w\.-]+)"
    match = re.search(pattern, text)
    return match.groupdict() if match else {}
