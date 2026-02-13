<h1 align="center">🖥️ Instalação Profissional do VirtualBox Headless em Ubuntu Server</h1>

<div align="center">
  <h3>Instalação automatizada do Oracle VirtualBox + Extension Pack via Script Bash</h3>
</div>

<hr>

<h2>🎯 Objetivo</h2>
<p>
Documentar a instalação automatizada do VirtualBox em Ubuntu Server sem interface gráfica,
baseado diretamente no script <b>install-virtualbox-headless.sh</b>.
</p>

<ul>
<li>Instala VirtualBox 7.0</li>
<li>Baixa Extension Pack compatível automaticamente</li>
<li>Configura módulos do kernel</li>
<li>Executa validação final da instalação</li>
</ul>

<hr>

<h2>🧠 Arquitetura</h2>

<pre>
Hardware
   ↓
Ubuntu Server (Kernel Linux)
   ↓
VirtualBox Headless (VBoxManage)
   ↓
Máquinas Virtuais
</pre>

<hr>

<h2>⚙️ Estratégia de Instalação</h2>

<table border="1" cellpadding="8">
<tr><th>Etapa</th><th>Descrição</th></tr>
<tr><td>Root</td><td>Valida execução via sudo/root</td></tr>
<tr><td>CPU</td><td>Verifica suporte vmx/svm</td></tr>
<tr><td>Dependências</td><td>Instala pacotes essenciais</td></tr>
<tr><td>Repo Oracle</td><td>Configura chave GPG e source list</td></tr>
<tr><td>Instalação</td><td>Instala virtualbox-7.0</td></tr>
<tr><td>Versão</td><td>Detecta versão via VBoxManage</td></tr>
<tr><td>Extension Pack</td><td>Download automático compatível</td></tr>
<tr><td>Módulos</td><td>Executa vboxconfig ou modprobe</td></tr>
<tr><td>Validação</td><td>Executa VBoxManage -v</td></tr>
</table>

<hr>

<h2>📦 Dependências Instaladas</h2>

<pre>
wget
curl
gnupg2
software-properties-common
apt-transport-https
ca-certificates
dkms
build-essential
linux-headers-generic
lsb-release
</pre>

<hr>

<h2>🚀 Fluxo Real Executado pelo Script</h2>

<ol>
<li>Valida execução como root</li>
<li>Verifica virtualização da CPU</li>
<li>Atualiza apt</li>
<li>Instala dependências</li>
<li>Baixa chave GPG Oracle</li>
<li>Cria keyring em /usr/share/keyrings</li>
<li>Cria repo virtualbox.list</li>
<li>Instala virtualbox-7.0</li>
<li>Valida VBoxManage</li>
<li>Detecta versão instalada</li>
<li>Baixa Extension Pack compatível</li>
<li>Instala Extension Pack automaticamente</li>
<li>Executa vboxconfig ou modprobe</li>
<li>Remove arquivo temporário</li>
<li>Mostra versão final instalada</li>
</ol>

<hr>

<h2>🔎 Comandos Técnicos Utilizados</h2>

<h3>Modo Seguro Bash</h3>

<pre>set -euo pipefail</pre>

<ul>
<li>-e → interrompe em erro</li>
<li>-u → bloqueia variáveis inexistentes</li>
<li>pipefail → captura erro em pipelines</li>
</ul>

<h3>Detecção de Virtualização</h3>

<pre>egrep -q '(vmx|svm)' /proc/cpuinfo</pre>

<ul>
<li>vmx → Intel VT-x</li>
<li>svm → AMD-V</li>
</ul>

<h3>Detecção da Versão VirtualBox</h3>

<pre>VBoxManage -v | cut -d 'r' -f1</pre>

<h3>Instalação Automática do Extension Pack</h3>

<pre>yes | VBoxManage extpack install --replace</pre>

<hr>

<h2>✅ Testes Pós Instalação</h2>

<h3>Versão</h3>
<pre>VBoxManage -v</pre>

<h3>Extension Pack</h3>
<pre>VBoxManage list extpacks</pre>

<h3>Módulos Kernel</h3>
<pre>lsmod | grep vbox</pre>

<h3>Criar VM Teste</h3>
<pre>
VBoxManage createvm --name teste --register
VBoxManage list vms
</pre>

<hr>

<h2>🔄 Manutenção</h2>

<h3>Atualizar VirtualBox</h3>

<pre>
sudo apt update
sudo apt upgrade
sudo /sbin/vboxconfig
</pre>

<h3>Atualizar Extension Pack</h3>

<p>Reexecute o script completo.</p>

<hr>

<h2>⚠️ Troubleshooting</h2>

<h3>Módulos não carregam</h3>

<pre>sudo /sbin/vboxconfig</pre>

<h3>Erro DKMS</h3>

<pre>
sudo apt install --reinstall build-essential dkms linux-headers-$(uname -r)
</pre>

<h3>Falha módulo manual</h3>

<pre>modprobe vboxdrv</pre>

<hr>

<h2 align="center">📌 Documento baseado diretamente no script install-virtualbox-headless.sh</h2>
<p align="center">Criado por Cassiano Projetos IT</p>
