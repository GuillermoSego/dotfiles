# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing **Neovim**, **Tmux**, **Herdr**, and **Zsh** configurations. Targets macOS, Linux, and WSL environments.

## Installation & Deployment

```bash
# Fresh machine: install everything from zero (idempotent, safe to re-run)
./bootstrap.sh

# Symlinks only (if dependencies are already installed)
./install.sh

# Remove symlinks
./uninstall.sh
```

`bootstrap.sh` handles the full setup: Homebrew, brew packages (neovim, tmux, herdr, fzf, lazygit, go, etc.), Oh-My-Zsh + plugins, TPM, NVM + Node.js, Python tools (black, debugpy), Rust + stylua, Go toolchain, symlinks, default shell, and headless plugin installs. Mason + mason-tool-installer auto-install LSP servers, formatters, and debuggers on first launch. The `linux` branch has a WSL/Ubuntu variant using apt.

Symlinks are created by `install.sh` (not GNU Stow). The directory layout mirrors the home directory structure: `nvim/.config/nvim/` → `~/.config/nvim/`, `tmux/.tmux.conf` → `~/.tmux.conf`, `zsh/.zshrc` → `~/.zshrc`.

## Neovim Architecture

**Entry point:** `nvim/.config/nvim/init.lua` — sets editor options (spaces, 4-width tabs, line numbers), leader key (`<space>`), and bootstraps lazy.nvim.

**Config modules:**
- `lua/config/lazy.lua` — All plugin declarations and keymaps. Each plugin's config and keybindings are defined inline within the lazy.nvim spec.
- `lua/config/lsp.lua` — LSP module exporting `on_attach()`, `get_capabilities()`, `setup_diagnostics()`, and `setup()`. Configures **Pyright** + **Ruff** (Python), **gopls** (Go), and **lua_ls** (Lua). Mason auto-installs LSP servers, `mason-tool-installer` auto-installs formatters/debuggers.
- `lua/config/sql.lua` — Fast query flow on top of vim-dadbod/dadbod-ui: `new_query()` opens a connected scratch buffer without the drawer, `exec_statement()` runs only the statement under the cursor, `attach()` wires the buffer-local maps from the `FileType sql` autocmd.

**Language support:**
- **Go**: gopls (LSP), gofumpt + goimports-reviser + golines (formatting), delve (debugging via nvim-dap-go)
- **Python**: pyright (type checking), ruff (linting/formatting), black (formatting), debugpy (debugging)
- **Lua**: lua_ls (LSP), stylua (formatting)
- **Web**: prettier (JS/TS/HTML/CSS/YAML/MD)

**Key plugin groups:** Telescope (fuzzy finding), mini.files (file explorer with Miller columns + preview), nvim-cmp + LuaSnip (completion), Treesitter (syntax), nvim-dap (debugging), Conform (formatting), Cyberdream (theme), noice.nvim (UI).

**File explorer:** mini.files replaces Neo-tree. `<leader>e` opens Miller columns at current file, `-` is a quick alias, `<C-n>` toggles from project root. Git status is shown via colored lines (Cyberdream palette). Navigation: `h`/`l` (in/out folders), `j`/`k` (up/down), `<CR>` (open + close), `=` (sync changes to disk).

**SQL / databases:** vim-dadbod + dadbod-ui, tuned for Redshift (`db_ui_use_postgres_views = 0`, table helpers over `svv_columns`/`svv_table_info`). Connections live in `~/.local/share/nvim/db_ui/connections.json` (never in the repo). `<leader>Du` drawer, `<leader>Dq` connected scratch buffer, `<leader>Df` attach the current `.sql` file to a connection. `<leader><CR>` executes the statement under the cursor (or the visual selection); `<leader>S` executes the whole buffer. Scratch queries go to `~/.cache/nvim/db_ui_queries`, saved ones to the `db_ui` data dir via `<leader>W`.

**Keymap conventions:** Leader-prefixed groups organized by function — `f` (find), `c` (code), `g` (git), `d` (debug), `dg` (debug go), `x` (diagnostics), `s` (symbols), `l` (LSP), `h` (git hunks), `D` (database). `which-key` provides discovery.

## Tmux Configuration

`tmux/.tmux.conf` — Prefix is `Ctrl+Space`. Cyberdream Powerline theme. Vim-style pane navigation (`h/j/k/l`) with `vim-tmux-navigator` for seamless vim/tmux switching. TPM manages plugins (resurrect, continuum, fzf, yank, thumbs, vim-tmux-navigator). Clipboard integration is OS-aware via `tmux-copy` script (pbcopy/xclip/wl-copy/clip.exe).

`tmux/tmux-sessionizer` — Cyberdream-themed fzf session manager. `prefix+s` (switch sessions with preview, ctrl-x kill, ctrl-r rename, ctrl-n new), `prefix+w` (window switcher), `prefix+X` (multi-select kill). Uses tab-delimited parsing for reliable field extraction.

## Herdr Configuration

`herdr/.config/herdr/config.toml` → `~/.config/herdr/config.toml` (only the file is symlinked; herdr keeps its runtime state elsewhere). Herdr is an agent-aware terminal multiplexer used alongside tmux for running several Claude Code sessions in parallel: sidebar shows each agent as blocked/working/done/idle. Meant to run in its own terminal tab, outside tmux. Prefix is `Ctrl+Space` (same as tmux; switch to `ctrl+b` if nesting inside tmux). Keys mirror tmux: `prefix h/j/k/l` focus, `prefix |`/`v` and `prefix -` split, `prefix a` agent goto picker (`b` filters blocked agents), `prefix g` lazygit popup (as in tmux), tab bar at the bottom, `prefix ,`/`.` previous/next agent, `prefix q` detach. Cyberdream colors via `[theme.custom]`. Claude session restore requires a one-time `herdr integration install claude` (writes a `SessionStart` hook to `~/.claude/settings.json`, outside this repo); `bootstrap.sh` runs it automatically (Phase 12).

## Claude Code Skills

`claude/.claude/skills/<name>/` → `~/.claude/skills/<name>/`. `install.sh` links each skill directory individually (never the whole `~/.claude`, which holds history, sessions and credentials), so adding a new folder there is enough. `herdr/SKILL.md` is generated with `herdr --skill`; regenerate it after upgrading herdr (`herdr --skill > claude/.claude/skills/herdr/SKILL.md`). It teaches Claude, running inside a herdr pane (`HERDR_ENV=1`), to split panes, start other agents (`herdr agent start <name> --kind claude`), prompt them and wait for their state.

## Zsh Configuration

`zsh/.zshrc` — Oh-My-Zsh with Powerlevel10k theme. Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting. Aliases `vim` to `nvim`. Optional integrations for Conda, NVM, and Google Cloud SDK.

## Commit Style

Commits use bracketed prefixes: `[feat]`, `[fix]`, `[FEAT]`, `chore:`. Example: `[feat] add plugins`.
