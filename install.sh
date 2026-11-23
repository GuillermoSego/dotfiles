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
link "herdr/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Skills de Claude Code: se enlaza cada skill por separado (nunca ~/.claude
# entero, que guarda historial, sesiones y credenciales).
for skill in "$REPO_DIR"/claude/.claude/skills/*/; do
  name="$(basename "$skill")"
  link "claude/.claude/skills/$name" "$HOME/.claude/skills/$name"
done

# asegurar que los scripts tengan permisos de ejecución
chmod +x "$REPO_DIR/tmux/tmux-copy"
chmod +x "$REPO_DIR/tmux/tmux-sessionizer"

# crear symlinks en ~/bin
link "tmux/tmux-copy" "$HOME/bin/tmux-copy"
link "tmux/tmux-sessionizer" "$HOME/bin/tmux-sessionizer"

echo "[✓] Dotfiles instalados."
[ -d "$BACKUP_DIR" ] && echo "    Backups guardados en $BACKUP_DIR"
