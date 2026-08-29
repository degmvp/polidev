# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU13 - Gerenciamento de Containers com Docker
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux / Docker
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta os comandos essenciais para
# gerenciamento do ciclo de vida de containers, permitindo
# o isolamento preciso de aplicações polyglot e bancos de dados.
#
# ATENÇÃO:
# Containers são stateless por natureza. Qualquer dado escrito
# dentro do container será perdido ao removê-lo. Para dados
# persistentes (Bancos de Dados), o uso de Volumes é obrigatório.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Verificar instalação e versão do Docker
# ==========================================================
docker --version

# ==========================================================
# ETAPA 02. Baixar imagem oficial do repositório
# ==========================================================
docker pull alpine:latest

# Confirmar imagem instalada
docker images

# ==========================================================
# ETAPA 03. Executar container em modo interativo
# ==========================================================
docker run -it --name polydev_test alpine /bin/sh

# (Dentro do container execute "exit")

# ==========================================================
# ETAPA 04. Listar containers ativos e inativos
# ==========================================================
docker ps
docker ps -a

# ==========================================================
# ETAPA 05. Executar serviço mapeando portas
# ==========================================================
docker run -d -p 8080:80 --name polydev_web nginx

# Confirmar container em execução
docker ps

# ==========================================================
# ETAPA 06. Persistir dados utilizando Volumes
# ==========================================================
docker volume create polydev_db_data

docker run -d \
--name polydev_postgres \
-v polydev_db_data:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=secret \
postgres

# Confirmar volumes existentes
docker volume ls

# ==========================================================
# ETAPA 07. Limpeza de recursos órfãos
# ==========================================================
docker system prune -a

# ==========================================================
# ETAPA 08. Exibir utilização de recursos
# ==========================================================
docker stats

# ==========================================================
# ETAPA 09. Inspecionar um container
# ==========================================================
docker inspect polydev_web

# ==========================================================
# ETAPA 10. Confirmar ambiente Docker
# ==========================================================
docker ps -a
docker images
docker volume ls