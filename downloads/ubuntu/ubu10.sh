# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU10 - Docker on Ubuntu
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta a instalação e utilização
# básica do Docker no Ubuntu Linux.
#
# ATENÇÃO:
# O Docker é uma das principais plataformas de
# conteinerização utilizadas em ambientes corporativos,
# DevOps, Cloud Computing e Data Engineering.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Atualizar repositórios
# ==========================================================
sudo apt update

# ==========================================================
# ETAPA 02. Instalar dependências
# ==========================================================
sudo apt install -y ca-certificates curl gnupg lsb-release

# ==========================================================
# ETAPA 03. Adicionar chave oficial do Docker
# ==========================================================
curl -fsSL https://download.docker.com/linux/ubuntu/gpg
sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

# ==========================================================
# ETAPA 04. Adicionar repositório Docker
# ==========================================================
dpkg --print-architecture
lsb_release -cs
sudo tee /etc/apt/sources.list.d/docker.list

# ==========================================================
# ETAPA 05. Atualizar catálogo de pacotes
# ==========================================================
sudo apt update

# ==========================================================
# ETAPA 06. Instalar Docker Engine
# ==========================================================
sudo apt install -y docker-ce docker-ce-cli containerd.io

# ==========================================================
# ETAPA 07. Verificar versão instalada
# ==========================================================
docker --version

# ==========================================================
# ETAPA 08. Verificar status do serviço Docker
# ==========================================================
sudo systemctl status docker

# ==========================================================
# ETAPA 09. Habilitar Docker no boot
# ==========================================================
sudo systemctl enable docker

# ==========================================================
# ETAPA 10. Executar container de teste
# ==========================================================
sudo docker run hello-world

# ==========================================================
# ETAPA 11. Listar containers em execução
# ==========================================================
sudo docker ps

# ==========================================================
# ETAPA 12. Listar todos os containers
# ==========================================================
sudo docker ps -a

# ==========================================================
# ETAPA 13. Listar imagens instaladas
# ==========================================================
sudo docker images

# ==========================================================
# ETAPA 14. Baixar imagem Ubuntu
# ==========================================================
sudo docker pull ubuntu

# ==========================================================
# ETAPA 15. Executar container Ubuntu
# ==========================================================
sudo docker run -it ubuntu bash

# ==========================================================
# ETAPA 16. Parar container
# ==========================================================
sudo docker stop CONTAINER_ID

# ==========================================================
# ETAPA 17. Remover container
# ==========================================================
sudo docker rm CONTAINER_ID

# ==========================================================
# ETAPA 18. Remover imagem
# ==========================================================
sudo docker rmi IMAGE_ID

# ==========================================================
# ETAPA 19. Verificar consumo de recursos
# ==========================================================
sudo docker stats

# ==========================================================
# ETAPA 20. Exibir informações do ambiente Docker
# ==========================================================
sudo docker info
