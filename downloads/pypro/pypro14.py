# POLYDEV | Python Professional Functions
# 14 - Função para uso de configuração dinâmica por arquivo YAML
#
# Finalidade:
# Facilitar parametrização e ajustes sem alterar código fonte.

import yaml

def carregar_configuracao(caminho_arquivo):
    with open(caminho_arquivo, 'r') as f:
        return yaml.safe_load(f)

config = carregar_configuracao('config.yaml')
print(config['database']['host'])
