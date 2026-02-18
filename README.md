# Dotfiles

Personal dev environment for **macOS** and **WSL/Ubuntu**, ready to install on a fresh machine with a single command.

Includes:
- **Neovim** — LSP, Treesitter, Telescope, nvim-dap, lazy.nvim (~47 plugins)
- **Tmux** — Catppuccin Mocha theme, vim-tmux-navigator, TPM plugins
- **Zsh** — Oh-My-Zsh + Powerlevel10k + autosuggestions + syntax highlighting

## Install from zero

Clone the repo and run the bootstrap script:

```bash
git clone https://github.com/GuillermoSego/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This single script installs **everything** from scratch (idempotent, safe to re-run):

| Phase | What it installs |
|-------|-----------------|
| 1 | Homebrew (if not present) |
| 2 | Brew packages (neovim, tmux, fzf, ripgrep, fd, jq, lazygit, python3, etc.) |
| 3 | Oh-My-Zsh + Powerlevel10k + zsh plugins |
| 4 | TPM (Tmux Plugin Manager) |
| 5 | NVM + Node.js LTS + prettier |
| 6 | Python tools (black, debugpy) |
| 7 | Rust + stylua |
| 8 | Symlinks via `install.sh` |
| 9 | Sets zsh as default shell |
| 10 | Headless plugin installs (TPM, lazy.nvim, Mason, Treesitter) |

> **WSL/Ubuntu**: Switch to the `linux` branch — its `bootstrap.sh` uses apt instead of Homebrew.

## Symlinks only

If dependencies are already installed and you just need the symlinks:

```bash
./install.sh
```

This creates symlinks from `$HOME` to the repo files and backs up any existing configs to `~/.dotfiles_backup/YYYYMMDD-HHMMSS/`.

## Update configs

```bash
cd ~/dotfiles
git pull
./install.sh   # re-applies symlinks if needed
```

To save your changes:

```bash
cd ~/dotfiles
git add .
git commit -m "[feat] description"
git push
```

## Uninstall

Remove symlinks (keeps repo files intact):

```bash
./uninstall.sh
```

## Repo structure

```
dotfiles/
├── nvim/.config/nvim/      -> ~/.config/nvim/
│   ├── init.lua             # entry point, options, leader key
│   └── lua/config/
│       ├── lazy.lua         # all plugin specs + keymaps
│       └── lsp.lua          # LSP servers (pyright, ruff)
├── tmux/.tmux.conf          -> ~/.tmux.conf
├── tmux/tmux-copy           -> ~/bin/tmux-copy
├── zsh/.zshrc               -> ~/.zshrc
├── bootstrap.sh             # full environment setup from zero
├── install.sh               # symlinks + backups
└── uninstall.sh             # remove symlinks
```

## Key bindings reference

### Tmux (prefix: `Ctrl+Space`)

| Key | Action |
|-----|--------|
| `prefix \|` | Split horizontal |
| `prefix -` | Split vertical |
| `prefix h/j/k/l` | Navigate panes |
| `Ctrl+h/j/k/l` | Navigate panes (vim-aware) |
| `prefix g` | Lazygit popup |
| `prefix s` | Fuzzy session switcher |
| `prefix f` | tmux-fzf |
| `prefix T` | tmux-thumbs (copy URLs/paths) |
| `prefix r` | Reload config |

### Neovim (leader: `Space`)

| Key | Action |
|-----|--------|
| `Ctrl+p` / `<leader>ff` | Find files |
| `Ctrl+f` / `<leader>fg` | Live grep |
| `<leader><leader>` | Switch buffers |
| `<leader>e` | Neo-tree float |
| `Ctrl+n` | Toggle Neo-tree |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `gd` / `gr` / `gi` | Go to definition/references/implementation |
| `<leader>db` | Toggle breakpoint |
| `F5` | Start/continue debug |
| `<leader>a` | Toggle Aerial (symbols) |
| `<leader>cf` | Format buffer |
