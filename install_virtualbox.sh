#!/usr/bin/env bash
set -euo pipefail

########################################
# CONFIG
########################################

KEYRING_PATH="/usr/share/keyrings/virtualbox.gpg"
REPO_FILE="/etc/apt/sources.list.d/virtualbox.list"

########################################
# FUNÇÕES
########################################

log() {
    echo -e "\n[INFO] $1"
}

error_exit() {
    echo "[ERRO] $1" >&2
    exit 1
}

require_root_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "[INFO] sudo vai solicitar senha..."
        sudo true
    fi
}

check_virtualization() {
    log "Verificando suporte a virtualização..."
    if ! egrep -q '(vmx|svm)' /proc/cpuinfo; then
        error_exit "Virtualização não habilitada na BIOS (AMD-V / VT-x)."
    fi
}

install_dependencies() {
    log "Instalando dependências..."
    sudo apt-get update -y
    sudo apt-get install -y \
        wget \
        curl \
        gnupg2 \
        lsb-release \
        dkms \
        build-essential \
        ca-certificates
}

add_oracle_repo() {

    if [ ! -f "$KEYRING_PATH" ]; then
        log "Adicionando chave Oracle..."
        wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
        sudo gpg --dearmor -o "$KEYRING_PATH"
    else
        log "Chave Oracle já existe."
    fi

    if [ ! -f "$REPO_FILE" ]; then
        log "Adicionando repositório VirtualBox..."
        echo "deb [arch=amd64 signed-by=$KEYRING_PATH] \
https://download.virtualbox.org/virtualbox/debian \
$(lsb_release -cs) contrib" | \
        sudo tee "$REPO_FILE" >/dev/null
    else
        log "Repositório já configurado."
    fi
}

install_virtualbox() {
    log "Instalando VirtualBox..."
    sudo apt-get update -y
    sudo apt-get install -y virtualbox-7.0
}

install_extension_pack() {

    log "Detectando versão instalada..."
    VBOX_VERSION=$(VBoxManage -v | cut -d 'r' -f1)

    if [ -z "$VBOX_VERSION" ]; then
        error_exit "Não foi possível detectar a versão do VirtualBox."
    fi

    log "Versão detectada: $VBOX_VERSION"

    EXT_PACK="Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack"
    URL="https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/${EXT_PACK}"

    if VBoxManage list extpacks | grep -q "$VBOX_VERSION"; then
        log "Extension Pack já instalado."
        return
    fi

    log "Baixando Extension Pack..."
    wget -q --show-progress "$URL"

    log "Instalando Extension Pack..."
    yes | sudo VBoxManage extpack install "$EXT_PACK" --replace

    rm -f "$EXT_PACK"
}

verify_modules() {
    log "Verificando módulos do kernel..."
    sudo /sbin/vboxconfig || true
}

########################################
# EXECUÇÃO
########################################

require_root_sudo
check_virtualization
install_dependencies
add_oracle_repo
install_virtualbox
install_extension_pack
verify_modules

log "Instalação concluída com sucesso!"
VBoxManage -v
