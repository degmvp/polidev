# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU04 - Permissions and Ownership
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta o modelo de permissões e
# propriedade de arquivos e diretórios no Ubuntu Linux.
#
# ATENÇÃO:
# O entendimento de permissões é fundamental para a
# segurança, administração e operação do sistema.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Exibir permissões de arquivos
# ==========================================================
ls -l

# ==========================================================
# ETAPA 02. Exibir permissões de um diretório
# ==========================================================
ls -ld /home

# ==========================================================
# ETAPA 03. Compreender o modelo rwx
# ==========================================================
# r = read
# w = write
# x = execute

# ==========================================================
# ETAPA 04. Alterar permissões utilizando chmod
# ==========================================================
chmod 755 arquivo.sh

# ==========================================================
# ETAPA 05. Tornar um script executável
# ==========================================================
chmod +x arquivo.sh

# ==========================================================
# ETAPA 06. Remover permissão de escrita
# ==========================================================
chmod u-w arquivo.sh

# ==========================================================
# ETAPA 07. Alterar proprietário de um arquivo
# ==========================================================
sudo chown usuario01 arquivo.sh

# ==========================================================
# ETAPA 08. Alterar proprietário e grupo
# ==========================================================
sudo chown usuario01:desenvolvedores arquivo.sh

# ==========================================================
# ETAPA 09. Alterar grupo de um arquivo
# ==========================================================
sudo chgrp desenvolvedores arquivo.sh

# ==========================================================
# ETAPA 10. Aplicar permissões recursivamente
# ==========================================================
chmod -R 755 projeto/

# ==========================================================
# ETAPA 11. Aplicar ownership recursivamente
# ==========================================================
sudo chown -R usuario01:desenvolvedores projeto/

# ==========================================================
# ETAPA 12. Verificar permissões de diretórios críticos
# ==========================================================
ls -ld /etc
ls -ld /var
ls -ld /home

# ==========================================================
# ETAPA 13. Exibir proprietário e grupo dos arquivos
# ==========================================================
ls -l

# ==========================================================
# ETAPA 14. Verificar permissões numéricas
# ==========================================================
stat arquivo.sh

# ==========================================================
# ETAPA 15. Revisar permissões após alterações
# ==========================================================
ls -l arquivo.sh
