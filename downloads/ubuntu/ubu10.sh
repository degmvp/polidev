# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU10 - Gerenciamento Avançado de Disco e LVM
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta os comandos essenciais para
# gerenciamento de discos utilizando LVM (Logical Volume Manager),
# permitindo a criação e o redimensionamento de partições
# lógicas em tempo real sem reinicialização do servidor.
#
# ATENÇÃO:
# Operações de disco são irreversíveis. Aplique estes
# comandos apenas em ambientes de teste ou com backup
# garantido em produção.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Identificar discos físicos disponíveis
# ==========================================================
lsblk

# ==========================================================
# ETAPA 02. Verificar instalação do LVM
# ==========================================================
sudo apt install -y lvm2

# ==========================================================
# ETAPA 03. Criar Partição Física (Physical Volume - PV)
# ==========================================================
sudo pvcreate /dev/sdb

# ==========================================================
# ETAPA 04. Criar Grupo de Volume (Volume Group - VG)
# ==========================================================
sudo vgcreate vg_polydev /dev/sdb

# Verificar o Volume Group criado
sudo vgdisplay

# ==========================================================
# ETAPA 05. Criar Volume Lógico (Logical Volume - LV)
# ==========================================================
sudo lvcreate -L 50G -n lv_dados vg_polydev

# Verificar o Logical Volume criado
sudo lvdisplay

# ==========================================================
# ETAPA 06. Formatar o Volume Lógico com sistema de arquivos
# ==========================================================
sudo mkfs.ext4 /dev/vg_polydev/lv_dados

# ==========================================================
# ETAPA 07. Montar o volume de forma persistente via fstab
# ==========================================================
sudo mkdir -p /mnt/dados

blkid /dev/vg_polydev/lv_dados

# Copie o UUID retornado e substitua no comando abaixo
echo 'SEU_UUID_AQUI /mnt/dados ext4 defaults 0 2' | sudo tee -a /etc/fstab

sudo mount -a

# ==========================================================
# ETAPA 08. Confirmar montagem do volume
# ==========================================================
df -h
mount | grep /mnt/dados

# ==========================================================
# ETAPA 09. Redimensionar volume em tempo real (Expansão)
# ==========================================================

# Adiciona 20G ao volume lógico
sudo lvextend -L +20G /dev/vg_polydev/lv_dados

# Expande o sistema de arquivos para ocupar o novo espaço
sudo resize2fs /dev/vg_polydev/lv_dados

# ==========================================================
# ETAPA 10. Confirmar expansão do volume
# ==========================================================
df -h
sudo lvdisplay