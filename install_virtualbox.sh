#!/usr/bin/env bash
#
# Script: install-virtualbox-headless.sh
# Descrição: Instalação automatizada do VirtualBox Headless + Extension Pack
# Uso: sudo ./install-virtualbox-headless.sh

set -euo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

# Verificar root
if [[ $EUID -ne 0 ]]; then
    error "Execute como root ou sudo"
fi

# Verificar virtualização
log "🔍 Verificando suporte à virtualização..."
if egrep -q '(vmx|svm)' /proc/cpuinfo; then
    log "✅ Virtualização suportada"
else
    error "Virtualização não habilitada na BIOS"
fi

# Atualizar sistema e dependências
log "📦 Instalando dependências..."
apt-get update
apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    dkms \
    build-essential \
    linux-headers-generic \
    lsb-release

# Adicionar chave Oracle
log "🔑 Configurando repositório Oracle VirtualBox..."
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
| gpg --dearmour -o /usr/share/keyrings/oracle-virtualbox.gpg

if [[ ! -f /usr/share/keyrings/oracle-virtualbox.gpg ]]; then
    error "Falha ao importar chave GPG"
fi

# Adicionar repo
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" \
> /etc/apt/sources.list.d/virtualbox.list

# Instalar VirtualBox
log "🖥️ Instalando VirtualBox..."
apt-get update
apt-get install -y virtualbox-7.0

# Validar instalação
command -v VBoxManage >/dev/null || error "VirtualBox não foi instalado corretamente"

# Detectar versão
VB_VERSION=$(VBoxManage -v | cut -d 'r' -f1)
log "📌 Versão detectada: $VB_VERSION"

# Baixar Extension Pack
EXT_PACK="Oracle_VM_VirtualBox_Extension_Pack-${VB_VERSION}.vbox-extpack"
log "📥 Baixando Extension Pack..."
wget -q "https://download.virtualbox.org/virtualbox/${VB_VERSION}/${EXT_PACK}" -O "/tmp/${EXT_PACK}"

# Instalar Extension Pack
log "🧩 Instalando Extension Pack..."
yes | VBoxManage extpack install --replace "/tmp/${EXT_PACK}"

# Recompilar módulos
log "⚡ Configurando módulos do kernel..."
if command -v vboxconfig &> /dev/null; then
    /sbin/vboxconfig
else
    log "vboxconfig não encontrado, carregando módulo manualmente"
    modprobe vboxdrv || error "Falha ao carregar módulo vboxdrv"
fi

# Limpeza
rm -f "/tmp/${EXT_PACK}"

# Validação final
log "✅ Instalação concluída!"
VBoxManage -v
