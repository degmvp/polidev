# ==========================================================
# POLYDEV | Kali Engineering
# KAL04 - Quebra de Hashes e Criptografia Prática
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento demonstra o processo de análise e quebra
# de senhas armazenadas em formato de hash. Aborda também
# conceitos básicos de criptografia simétrica para
# proteção de dados sensíveis em trânsito ou repouso.
#
# ATENÇÃO:
# A quebra de senhas só deve ser realizada em hashes que
# você possui permissão para testar (auditorias próprias
# ou desafios CTF). Nunca tente descriptografar dados de
# terceiros sem autorização formal.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Simular um vazamento de banco de dados (Hashes)
# ==========================================================
# Cria um arquivo simulando usuários e senhas hasheadas em MD5
# A senha do admin é "password" e do guest é "guest"
echo "admin:5f4dcc3b5aa765d61d8327deb882cf99" > polydev_hashes.txt
echo "guest:084e0343a0486ff05530df6c705c8bb4" >> polydev_hashes.txt

# ==========================================================
# ETAPA 02. Identificar o formato do Hash
# ==========================================================
# O Hashcat possui um utilitário nativo para identificar o tipo baseado na estrutura
hashcat --example-hashes | grep -i "5f4dcc3b5aa765d61d8327deb882cf99"
# Resultado esperado no output: Mode 0 (MD5)

# ==========================================================
# ETAPA 03. Quebra de Hash com John the Ripper (Dicionário)
# ==========================================================
# Utiliza uma wordlist famosa (Descompacte-a antes: gunzip /usr/share/wordlists/rockyou.txt.gz)
john --wordlist=/usr/share/wordlists/rockyou.txt polydev_hashes.txt

# ==========================================================
# ETAPA 04. Exibir senhas quebradas pelo John
# ==========================================================
# O John oculta as senhas por padrão durante a execução
john --show polydev_hashes.txt

# ==========================================================
# ETAPA 05. Quebra de Hash com Hashcat (Aceleração GPU)
# ==========================================================
# -m 0: Força o modo MD5
# -a 0: Define o ataque como Dicionário
hashcat -m 0 -a 0 polydev_hashes.txt /usr/share/wordlists/rockyou.txt

# ==========================================================
# ETAPA 06. Criptografar arquivos sensíveis com GPG (Simétrica)
# ==========================================================
# Gera um arquivo de teste
echo "Dados sigilosos do POLYDEV" > segredo.txt
# Criptografa o arquivo usando uma senha (simétrica)
# Ele vai pedir para você digitar e confirmar uma senha
gpg -c segredo.txt

# ==========================================================
# ETAPA 07. Descriptografar arquivo GPG
# ==========================================================
# Solicita a senha definida na ETAPA 06 para recuperar o dado original
gpg -d segredo.txt.gpg > segredo_recuperado.txt
cat segredo_recuperado.txt