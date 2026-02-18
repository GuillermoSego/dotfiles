# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing **Neovim**, **Tmux**, and **Zsh** configurations. Targets macOS, Linux, and WSL environments.

## Installation & Deployment

```bash
# Fresh machine: install everything from zero (idempotent, safe to re-run)
./bootstrap.sh

# Symlinks only (if dependencies are already installed)
./install.sh

# Remove symlinks
./uninstall.sh
```

`bootstrap.sh` handles the full setup: system packages (apt), Neovim (AppImage), Oh-My-Zsh + plugins, TPM, NVM + Node.js, Python tools (black, debugpy), Rust + stylua, lazygit, symlinks, default shell, and headless plugin installs. The `main` branch has a macOS variant using Homebrew.

Symlinks are created by `install.sh` (not GNU Stow). The directory layout mirrors the home directory structure: `nvim/.config/nvim/` → `~/.config/nvim/`, `tmux/.tmux.conf` → `~/.tmux.conf`, `zsh/.zshrc` → `~/.zshrc`.

## Neovim Architecture

**Entry point:** `nvim/.config/nvim/init.lua` — sets editor options (spaces, 4-width tabs, line numbers), leader key (`<space>`), and bootstraps lazy.nvim.

**Two config modules:**
- `lua/config/lazy.lua` — All plugin declarations and keymaps (~47 plugins). Each plugin's config and keybindings are defined inline within the lazy.nvim spec.
- `lua/config/lsp.lua` — LSP module exporting `on_attach()`, `get_capabilities()`, `setup_diagnostics()`, and `setup()`. Currently configures **Pyright** (type checking) and **Ruff** (linting/formatting) for Python. Mason auto-installs LSP servers.

**Key plugin groups:** Telescope (fuzzy finding), Neo-tree (file explorer), nvim-cmp + LuaSnip (completion), Treesitter (syntax), nvim-dap (debugging), Conform (formatting: black, stylua, prettier, jq), Catppuccin (theme), noice.nvim (UI).

**Keymap conventions:** Leader-prefixed groups organized by function — `f` (find), `c` (code), `g` (git), `d` (debug), `x` (diagnostics), `s` (symbols), `l` (LSP), `n` (neo-tree). `which-key` provides discovery.

## Tmux Configuration

`tmux/.tmux.conf` — Prefix is `Ctrl+Space`. Vim-style pane navigation (`h/j/k/l`) with `vim-tmux-navigator` for seamless vim/tmux switching. Catppuccin Mocha theme. TPM manages plugins (resurrect, continuum, fzf, yank, thumbs). Clipboard integration is OS-aware (pbcopy/xclip/wl-copy/clip.exe).

## Zsh Configuration

`zsh/.zshrc` — Oh-My-Zsh with Powerlevel10k theme. Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting. Aliases `vim` to `nvim`. Optional integrations for Conda, NVM, and Google Cloud SDK.

## Commit Style

Commits use bracketed prefixes: `[feat]`, `[fix]`, `[FEAT]`, `chore:`. Example: `[feat] add plugins`.
