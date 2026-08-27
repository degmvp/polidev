06 - Leitura de JSON Grande (Streaming)

import json

def json_stream_reader(file_path: str):
    """
    Lê arquivo JSON Array grande sem carregar tudo na memória.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        f.readline()  # pula primeira linha '['
        for line in f:
            line = line.strip()
            if line in (',', ']'):
                continue
            if line.endswith(','):
                line = line[:-1]
            try:
                yield json.loads(line)
            except:
                continue