# ==========================================================
# POLYDEV | Kali Engineering
# KAL00 - Instalação Segura e Introdução via WSL2
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux / WSL2 (Windows Subsystem for Linux)
#
# LINGUAGEM:
# PowerShell / Bash
#
# OBJETIVO:
# Este documento apresenta o método mais seguro e limpo para
# instlar o Kali Linux em ambientes de desenvolvimento sem
# a necessidade de particionamento de disco rígido ou dual-boot,
# utilizando a arquitetura WSL2 nativa do Windows.
#
# ATENÇÃO:
# O Kali Linux é uma distribuição voltada para testes de
# penetração. Não utilize-a como seu sistema operacional
# pessoal diário. Mantenha-a isolada para fins de estudo.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Habilitar o recurso WSL no Windows (Run as Admin)
# ==========================================================
wsl --install

# ==========================================================
# ETAPA 02. Reiniciar o sistema operacional Windows
# ==========================================================
# O Windows solicitará reinicialização para aplicar as mudanças.
# Após reiniciar, uma janela de terminal do Ubuntu abrirá
# automaticamente. Feche essa janela, pois instalaremos o Kali.

# ==========================================================
# ETAPA 03. Instalar o Kali Linux via linha de comando
# ==========================================================
# Baixa e instala a imagem oficial do Kali direto da Microsoft Store
wsl --install -d kali-linux

# ==========================================================
# ETAPA 04. Configurar usuário e senha de acesso
# ==========================================================
# Após a instalação, o terminal iniciará solicitando:
# - New UNIX username: [Crie seu usuário, ex: polydev]
# - New password: [Crie uma senha forte, ela não aparecerá na tela]

# ==========================================================
# ETAPA 05. Atualizar o sistema para a versão mais recente
# ==========================================================
sudo apt update
sudo apt full-upgrade -y

# ==========================================================
# ETAPA 06. Instalar os pacotes padrão de segurança (Headless)
# ==========================================================
# Instala as ferramentas essenciais de rede, exploração e enumeração
# sem a necessidade da interface gráfica pesada.
sudo apt install -y kali-linux-headless

# ==========================================================
# ETAPA 07. Validar a instalação e ambiente isolado
# ==========================================================
cat /etc/os-release
whoami