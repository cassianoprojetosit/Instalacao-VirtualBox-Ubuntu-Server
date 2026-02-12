# 🖥️ Instalação Profissional do VirtualBox Headless em Ubuntu Server

<div align="center">
  <img src="https://img.shields.io/badge/VirtualBox-7.0+-blue?style=for-the-badge&logo=virtualbox" alt="VirtualBox 7.0+">
  <img src="https://img.shields.io/badge/Ubuntu_Server-20.04+-orange?style=for-the-badge&logo=ubuntu" alt="Ubuntu Server 20.04+">
  <img src="https://img.shields.io/badge/Script-Bash-4EAA25?style=for-the-badge&logo=gnu-bash" alt="Script Bash">
  <img src="https://img.shields.io/badge/Modo-Headless-black?style=for-the-badge" alt="Modo Headless">
</div>

Documentação técnica completa para instalação automatizada do Oracle VirtualBox em Ubuntu Server sem interface gráfica.

## 📋 Índice

*   [🎯 Objetivo](#-objetivo)
*   [🧠 Visão Geral da Arquitetura](#-visão-geral-da-arquitetura)
*   [⚙️ Estratégia de Instalação](#%EF%B8%8F-estratégia-de-instalação)
*   [📜 Script de Instalação Automatizada](#-script-de-instalação-automatizada)
*   [🔎 Descrição Técnica dos Comandos](#-descrição-técnica-dos-comandos)
*   [🚀 Fluxo Executado Durante Instalação](#-fluxo-executado-durante-instalação)
*   [✅ Testes Pós-Instalação (OBRIGATÓRIO)](#-testes-pós-instalação-obrigatório)
*   [🔄 Manutenção Futura](#-manutenção-futura)
*   [⚠️ Boas Práticas em Servidores](#%EF%B8%8F-boas-práticas-em-servidores)
*   [🛠️ Troubleshooting](#%EF%B8%8F-troubleshooting)
*   [📈 Evolução Futura Recomendada](#-evolução-futura-recomendada)

## 🎯 Objetivo

Documentar o processo completo e automatizado de instalação do Oracle VirtualBox em Ubuntu Server (headless) utilizando:

*   ✅ Script Bash profissional com boas práticas
*   ✅ Repositório oficial Oracle
*   ✅ Extension Pack automático e compatível
*   ✅ Segurança, idempotência e logs estruturados
*   ✅ Base para automação em larga escala

## 🧠 Visão Geral da Arquitetura

**Ambiente-alvo:**

*   Servidor bare metal rodando Ubuntu Server
*   CPU com virtualização habilitada (AMD-V ou Intel VT-x)
*   Sem interface gráfica (modo headless)
*   Gerenciamento via CLI (VBoxManage)

**Modelo conceitual:**

```text
┌─────────────────┐
│    Hardware     │
│  (CPU, RAM, IO) │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Ubuntu Server  │
│  (kernel Linux) │
└────────┬────────┘
         ↓
┌─────────────────┐
│   VirtualBox    │
│  (VBoxManage)   │
└────────┬────────┘
         ↓
┌─────────────────┐
│   Máquinas      │
│   Virtuais      │
└─────────────────┘
```

## ⚙️ Estratégia de Instalação

Script automatizado com execução idempotente (pode rodar múltiplas vezes sem quebrar). Responsabilidades:

| Etapa | Descrição |
| :---- | :-------- |
| 🔍    | Validar suporte à virtualização na CPU |
| 📦    | Instalar dependências essenciais |
| 🔑    | Adicionar repositório oficial Oracle |
| 🖥️    | Instalar VirtualBox estável |
| 🔢    | Detectar versão instalada automaticamente |
| 📥    | Baixar Extension Pack compatível |
| 🧩    | Instalar extensão com aceite de licença |
| ⚡    | Recompilar módulos do kernel |
| ✅    | Validar instalação completa |

## 📜 Script de Instalação Automatizada

```bash
#!/usr/bin/env bash
#
# Script: install-virtualbox-headless.sh
# Descrição: Instalação automatizada do VirtualBox + Extension Pack
# Autor: Time de Infraestrutura
# Uso: sudo ./install-virtualbox-headless.sh

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função de log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

# Verificação de root
if [[ $EUID -ne 0 ]]; then
    error "Este script deve ser executado como root"
fi

# 1. Verificar virtualização
log "🔍 Verificando suporte à virtualização..."
if egrep -q '(vmx|svm)' /proc/cpuinfo; then
    log "✅ Virtualização habilitada"
else
    error "Virtualização não suportada ou desabilitada na BIOS"
fi

# 2. Atualizar índices e instalar dependências
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
    linux-headers-$(uname -r) \
    lsb-release

# 3. Adicionar repositório Oracle
log "🔑 Configurando repositório Oracle..."
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmour -o /usr/share/keyrings/oracle-virtualbox.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee /etc/apt/sources.list.d/virtualbox.list

# 4. Instalar VirtualBox
log "🖥️ Instalando VirtualBox 7.0..."
apt-get update
apt-get install -y virtualbox-7.0

# 5. Capturar versão instalada
VB_VERSION=$(VBoxManage -v | cut -d 'r' -f1)
log "📌 Versão detectada: $VB_VERSION"

# 6. Download do Extension Pack
log "📥 Baixando Extension Pack..."
EXT_PACK="Oracle_VM_VirtualBox_Extension_Pack-${VB_VERSION}.vbox-extpack"
wget -q "https://download.virtualbox.org/virtualbox/${VB_VERSION}/${EXT_PACK}" -O "/tmp/${EXT_PACK}"

# 7. Instalar Extension Pack
log "🧩 Instalando Extension Pack..."
yes | VBoxManage extpack install --replace "/tmp/${EXT_PACK}"

# 8. Recompilar módulos
log "⚡ Recompilando módulos do kernel..."
/sbin/vboxconfig

# 9. Limpeza
rm -f "/tmp/${EXT_PACK}"

# 10. Validação
log "✅ Instalação concluída!"
VBoxManage -v
```

## 🔎 Descrição Técnica dos Comandos

### Shebang e Modo Seguro

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Flag     | Efeito                               |
| :------- | :----------------------------------- |
| `-e`     | Interrompe execução ao primeiro erro |
| `-u`     | Impede uso de variáveis não declaradas |
| `pipefail` | Captura falhas em pipelines          |

### Verificação de Virtualização

```bash
egrep -q '(vmx|svm)' /proc/cpuinfo
```

| Flag  | Detecção    |
| :---- | :---------- |
| `vmx` | Intel VT-x  |
| `svm` | AMD-V       |

### Adição da Chave GPG

```bash
wget -qO- URL | gpg --dearmour -o /usr/share/keyrings/...
```

**Por quê?** Converte chave ASCII para formato binário seguro, exigido pelo `signed-by` no `sources.list`.

### Detecção do Codename Ubuntu

```bash
lsb_release -cs
```

**Retorna:** `jammy` (22.04), `noble` (24.04) ou `focal` (20.04)

### Parsing da Versão VirtualBox

```bash
VBoxManage -v | cut -d 'r' -f1
```

**Exemplo:** `7.0.14r161095` → `7.0.14`

### Instalação Automática do Extension Pack

```bash
yes | VBoxManage extpack install --replace "/tmp/${EXT_PACK}"
```

*   `yes`: Auto-aceita o contrato de licença
*   `--replace`: Substitui versão anterior se existir

## 🚀 Fluxo Executado Durante Instalação

*(O conteúdo original não forneceu um fluxo detalhado, apenas um título. Se houver um diagrama ou descrição, ele deve ser inserido aqui.)*

## ✅ Testes Pós-Instalação (OBRIGATÓRIO)

### 1. Versão instalada

```bash
VBoxManage -v
```

**Esperado:** `7.0.14` (ou superior)

### 2. Extension Pack ativo

```bash
VBoxManage list extpacks
```

**Esperado:**

```text
Extension Packs: 1
Pack no. 0:   Oracle VM VirtualBox Extension Pack
Version:      7.0.14
Status:       usable
```

### 3. Módulos do kernel carregados

```bash
lsmod | grep vbox
```

**Esperado:**

```text
vboxdrv
vboxnetflt
vboxnetadp
```

### 4. Criação de VM de teste

```bash
VBoxManage createvm --name teste --register
VBoxManage list vms
```

## 🔄 Manutenção Futura

### Atualizar VirtualBox

```bash
sudo apt update
sudo apt upgrade
sudo /sbin/vboxconfig   # obrigatório após upgrade
```

### Atualizar Extension Pack

**Recomendação:** Reexecutar o script completo. Ele:

*   Detecta nova versão do VirtualBox
*   Baixa o Extension Pack correspondente
*   Substitui a versão antiga automaticamente

### Atualizações de Kernel

Sempre que o kernel for atualizado:

```bash
sudo /sbin/vboxconfig
```

## ⚠️ Boas Práticas em Servidores

*   🚫 Não misturar VirtualBox com KVM no mesmo host
*   📊 Monitorar consumo de RAM das VMs (`vboxmanage showvminfo`)
*   💾 Snapshots com moderação (impacto em performance)
*   🔒 Isolar redes das VMs quando necessário (host-only vs NAT)
*   📀 Backups automatizados dos discos VDI
*   🔄 Manter kernel atualizado por segurança
*   📝 Documentar todas as VMs e suas finalidades

## 🛠️ Troubleshooting

### Problema: Módulos não carregam após boot

```bash
sudo /sbin/vboxconfig
```

### Problema: Extension Pack incompatível

```bash
# Remover extensão atual
VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"

# Reinstalar via script
./install-virtualbox-headless.sh
```

### Problema: Erro DKMS / headers não encontrados

```bash
sudo apt install --reinstall \
    build-essential \
    dkms \
    linux-headers-$(uname -r)
```

### Problema: VirtualBox não inicia VMs

```bash
# Verificar usuário no grupo vboxusers
sudo usermod -aG vboxusers $USER

# Verificar permissões do dispositivo
ls -la /dev/vboxdrv
```

## 📈 Evolução Futura Recomendada

Para ambientes de produção e alta densidade, considerar migração para:

| Tecnologia        | Benefício                               |
| :---------------- | :-------------------------------------- |
| KVM/libvirt       | Performance nativa, suporte em clouds   |
| cloud-init        | Provisionamento automatizado            |
| Templates         | Imagens base padronizadas               |
| Ansible/Terraform | Infraestrutura como código              |
| Proxmox VE        | Plataforma completa de virtualização    |

<div align="center">
  📌 **Nota:** VirtualBox é excelente para laboratórios, testes e desenvolvimento. Para produção crítica, avalie hipervisores tipo 1 (KVM, ESXi, Hyper-V).

  Documento mantido pela equipe de Infraestrutura
  Última atualização: 12/02/2026
</div>
