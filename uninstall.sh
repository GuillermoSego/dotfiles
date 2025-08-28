#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

remove_link () {
  local dest="$1"
  if [ -L "$dest" ]; then
    local target; target="$(readlink "$dest" || true)"
    if [[ "$target" == "$REPO_DIR"* ]]; then
      echo "Removing symlink: $dest"
      rm -f "$dest"
    else
      echo "Skipping $dest (not managed by dotfiles repo)"
    fi
  else
    echo "Skipping $dest (not a symlink)"
  fi
}

echo "[*] Removing symlinks created by dotfiles"

remove_link "$HOME/.zshrc"
remove_link "$HOME/.tmux.conf"
remove_link "$HOME/.config/nvim"

echo "[✓] Uninstall complete."
