#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL03 - Administração Tática: Usuários, Permissões e SSH
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento aborda o gerenciamento de identidade e
# acesso no ambiente Linux sob uma ótica de segurança.
# Entender a mecânica de permissões e o controle do sudo
# é o primeiro passo para prevenir escalonamentos de privilégio.
#
# ATENÇÃO:
# Em ambientes de pentest, nunca opere como usuário root
# constante. Use contas com privilégios minimizados e
# eleve o acesso apenas quando estritamente necessário.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Criação e gerenciamento de Usuários
# ==========================================================
# Cria um novo usuário sem diretório home padrão (comum para serviços)
sudo useradd -M -s /usr/sbin/nologin polydev_svc

# Cria um usuário com diretório home e bash padrão
sudo useradd -m -s /bin/bash auditor

# Define ou altera a senha do usuário recém-criado
sudo passwd auditor

# ==========================================================
# ETAPA 02. Gerenciamento de Grupos
# ==========================================================
# Cria um grupo exclusivo para a equipe de segurança
sudo groupadd sec_team

# Adiciona o usuário 'auditor' ao grupo 'sec_team' (GID secundário)
sudo usermod -aG sec_team auditor

# Valida os grupos e o GID (Group ID) primário do usuário
id auditor

# ==========================================================
# ETAPA 03. Permissões Tradicionais (UGO - User, Group, Others)
# ==========================================================
# Cria um arquivo de teste
echo "Dados restritos" > /tmp/relatorio.txt

# Altera o dono (chown) e o grupo do arquivo
sudo chown auditor:sec_team /tmp/relatorio.txt

# Aplica permissões rwx (Leitura=4, Escrita=2, Execução=1)
# Dono (rwx=7) | Grupo (rx=5) | Outros (nenhuma=0)
sudo chmod 750 /tmp/relatorio.txt

# Lista as permissões detalhadas em formato octal e legível
stat -c "%a %U:%G %n" /tmp/relatorio.txt

# ==========================================================
# ETAPA 04. Permissões Especiais: SUID, SGID e Sticky Bit
# ==========================================================
# SUID (4): Executa o binário com os privilégios do DONO do arquivo (Não do usuário que executou)
# Exemplo clássico: O binário passwd precisa escrever em /etc/shadow como root
sudo chmod u+s /usr/local/bin/polydev_tool

# SGID (2): Força novos arquivos criados no diretório a herdarem o GROUP do diretório
sudo chmod g+s /polydev_shared_folder

# Sticky Bit (1): Impede que usuários apaguem arquivos de outros em diretórios compartilhados (ex: /tmp)
sudo chmod +t /polydev_shared_folder

# Comando para encontrar arquivos com SUID ativo no sistema (Vetor de escalonamento comum)
find / -perm -4000 -type f 2>/dev/null

# ==========================================================
# ETAPA 05. Configuração Segura do Sudo (visudo)
# ==========================================================
# NEVER edit /etc/sudoers directly. Use visudo for syntax checking.
# Abre o editor seguro de políticas do sudo
sudo visudo

# Dentro do visudo, a política abaixo permite ao usuário 'auditor'
# rodar apenas comandos específicos sem pedir senha (NOPASSWD)
# auditor ALL=(ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/sqlmap

# ==========================================================
# ETAPA 06. Hardening do Serviço SSH
# ==========================================================
# Faz backup do arquivo original antes de alterar
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Desabilita o login direto do root via SSH (Mitiga ataques de força bruta diretos)
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Desabilita o uso de senhas fracas, permitindo SOMENTE chaves criptográficas (Key Pairs)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Reinicia o serviço para aplicar as novas regras de segurança
sudo systemctl restart sshd

# ==========================================================
# ETAPA 07. Geração e Distribuição de Chaves SSH
# ==========================================================
# Gera um par de chaves RSA de 4096 bits (Sem passphrase para automação, ou com passphrase para segurança)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/polydev_id_rsa

# Copia a chave pública para o servidor alvo (Habilita o login sem senha configurado na ETAPA 06)
ssh-copy-id -i ~/.ssh/polydev_id_rsa.pub auditor@192.168.1.105