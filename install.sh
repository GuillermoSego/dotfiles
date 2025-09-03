#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

backup() {
  local dest="$1"
  mkdir -p "$BACKUP_DIR$(dirname "$dest")"
  mv -v "$dest" "$BACKUP_DIR$dest"
}

link() {
  local src_rel="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$(readlink "$dest" 2>/dev/null)" != "$REPO_DIR/$src_rel" ]; then
      echo "[*] Backup de $dest"
      backup "$dest"
    fi
  fi
  ln -sfn "$REPO_DIR/$src_rel" "$dest"
  echo " -> $dest"
}

echo "[*] Instalando dotfiles desde $REPO_DIR"

link "nvim/.config/nvim" "$HOME/.config/nvim"
link "zsh/.zshrc"        "$HOME/.zshrc"
link "tmux/.tmux.conf"   "$HOME/.tmux.conf"

# asegurar que el script original tenga permisos de ejecución
chmod +x "$REPO_DIR/tmux/tmux-copy"

# crear symlink en ~/bin
link "tmux/tmux-copy" "$HOME/bin/tmux-copy"

echo "[✓] Dotfiles instalados."
[ -d "$BACKUP_DIR" ] && echo "    Backups guardados en $BACKUP_DIR"
