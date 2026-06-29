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

`bootstrap.sh` handles the full setup: system packages (apt), Neovim (AppImage), Oh-My-Zsh + plugins, TPM, NVM + Node.js, Python tools (black, debugpy), Rust + stylua, lazygit, symlinks, default shell, and headless plugin installs. Mason + mason-tool-installer auto-install LSP servers, formatters, and debuggers on first launch. The `main` branch has a macOS variant using Homebrew.

Symlinks are created by `install.sh` (not GNU Stow). The directory layout mirrors the home directory structure: `nvim/.config/nvim/` → `~/.config/nvim/`, `tmux/.tmux.conf` → `~/.tmux.conf`, `zsh/.zshrc` → `~/.zshrc`.

## Neovim Architecture

**Entry point:** `nvim/.config/nvim/init.lua` — sets editor options (spaces, 4-width tabs, line numbers), leader key (`<space>`), and bootstraps lazy.nvim.

**Two config modules:**
- `lua/config/lazy.lua` — All plugin declarations and keymaps. Each plugin's config and keybindings are defined inline within the lazy.nvim spec.
- `lua/config/lsp.lua` — LSP module exporting `on_attach()`, `get_capabilities()`, `setup_diagnostics()`, and `setup()`. Configures **Pyright** + **Ruff** (Python), **gopls** (Go), and **lua_ls** (Lua). Mason auto-installs LSP servers, `mason-tool-installer` auto-installs formatters/debuggers.

**Language support:**
- **Go**: gopls (LSP), gofumpt + goimports-reviser + golines (formatting), delve (debugging via nvim-dap-go)
- **Python**: pyright (type checking), ruff (linting/formatting), black (formatting), debugpy (debugging)
- **Lua**: lua_ls (LSP), stylua (formatting)
- **Web**: prettier (JS/TS/HTML/CSS/YAML/MD)

**Key plugin groups:** Telescope (fuzzy finding), mini.files (file explorer with Miller columns + preview), nvim-cmp + LuaSnip (completion), Treesitter (syntax), nvim-dap (debugging), Conform (formatting), Cyberdream (theme), noice.nvim (UI).

**File explorer:** mini.files replaces Neo-tree. `<leader>e` opens Miller columns at current file, `-` is a quick alias, `<C-n>` toggles from project root. Git status is shown via colored lines (Cyberdream palette). Navigation: `h`/`l` (in/out folders), `j`/`k` (up/down), `<CR>` (open + close), `=` (sync changes to disk).

**Keymap conventions:** Leader-prefixed groups organized by function — `f` (find), `c` (code), `g` (git), `d` (debug), `dg` (debug go), `x` (diagnostics), `s` (symbols), `l` (LSP), `h` (git hunks). `which-key` provides discovery.

## Tmux Configuration

`tmux/.tmux.conf` — Prefix is `Ctrl+Space`. Cyberdream Powerline theme. Vim-style pane navigation (`h/j/k/l`) with `vim-tmux-navigator` for seamless vim/tmux switching. TPM manages plugins (resurrect, continuum, fzf, yank, thumbs, vim-tmux-navigator). Clipboard integration is OS-aware via `tmux-copy` script (pbcopy/xclip/wl-copy/clip.exe).

`tmux/tmux-sessionizer` — Cyberdream-themed fzf session manager. `prefix+s` (switch sessions with preview, ctrl-x kill, ctrl-r rename, ctrl-n new), `prefix+w` (window switcher), `prefix+X` (multi-select kill). Uses tab-delimited parsing for reliable field extraction.

## Zsh Configuration

`zsh/.zshrc` — Oh-My-Zsh with Powerlevel10k theme. Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting. Aliases `vim` to `nvim`. Optional integrations for Conda, NVM, and Google Cloud SDK.

## Commit Style

Commits use bracketed prefixes: `[feat]`, `[fix]`, `[FEAT]`, `chore:`. Example: `[feat] add plugins`.
