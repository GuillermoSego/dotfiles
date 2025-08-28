# Dotfiles 🛠️

Mi entorno personal de trabajo para **Mac, Linux y WSL**, listo para instalar en cualquier máquina con un solo comando.

Incluye:
- **Zsh** (con soporte para Oh-My-Zsh)
- **Neovim** (configuración en `~/.config/nvim`)
- **Tmux** (con soporte para TPM)

## 📦 Requisitos

En una máquina nueva asegúrate de tener:

- **zsh**
- **neovim**
- **tmux**

Instálalos con tu gestor de paquetes:

```bash
sudo apt update
sudo apt install -y git zsh neovim tmux
```
En macOS:
```bash
brew install git zsh neovim tmux stow
```

## 🚀 Instalación
	
1.	Clona el repositorio en tu home:

```bash
git clone https://github.com/TU-USUARIO/dotfiles.git ~/dotfiles
cd ~/dotfiles
```
2.	Da permisos al instalador y ejecútalo:

```bash
chmod +x install.sh
./install.sh
```
Este script:
	•	Crea symlinks desde tu $HOME hacia los archivos de este repo.
	•	Hace backup de archivos existentes en ~/.dotfiles_backup/AAAAMMDD-HHMMSS.

3.	Reinicia la shell:

```bash
exec zsh
```

## ⚡ Post-instalación

### Oh-My-Zsh

Si aún no tienes instalado Oh-My-Zsh, ejecútalo (una sola vez):

```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

Tu .zshrc ya está en este repo, así que cargará automáticamente la configuración.

### Tmux plugins

Instala TPM (Tmux Plugin Manager):
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Después abre tmux y presiona:

prefix + I    # (Ctrl+b seguido de Shift+i)

para instalar los plugins definidos en ~/.tmux.conf.

## 🛠️ Mantenimiento
Para actualizar tus configs:
```bash
cd ~/dotfiles
git pull
./install.sh   # vuelve a aplicar symlinks si es necesario
```

Para editar y guardar cambios en cualquier dotfile:
Edita normalmente (nvim ~/.zshrc, nvim ~/.config/nvim/init.lua, etc.)
Luego guarda en git:
```bash
cd ~/dotfiles
git add .
git commit -m "update config"
git push
```

## 🔄 Desinstalar (opcional)

Si quieres quitar los symlinks (pero no borrar los archivos de tu repo):

```bash
./uninstall.sh
```

## 📂 Estructura del repo

dotfiles/
├── nvim/.config/nvim/      → ~/.config/nvim/
├── tmux/.tmux.conf         → ~/.tmux.conf
├── zsh/.zshrc              → ~/.zshrc
├── install.sh              # instalador (symlinks)
└── uninstall.sh            # desinstalador


## ✨ Notas

Los backups de configuraciones previas se guardan en:
```bash
~/.dotfiles_backup/AAAAMMDD-HHMMSS/
```

