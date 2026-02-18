#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║           macOS Bootstrap — Full Dev Environment            ║
# ║     Idempotent: safe to re-run, skips what's installed      ║
# ╚══════════════════════════════════════════════════════════════╝

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Helpers ───────────────────────────────────────────────────
info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
err()   { printf '\033[1;31m[ERR]\033[0m   %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

# ── Phase 1: Homebrew ────────────────────────────────────────
install_homebrew() {
    info "Phase 1: Homebrew"
    if has brew; then
        ok "Homebrew already installed"
        return
    fi
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Source brew for this session (Apple Silicon path)
    if [ -d "/opt/homebrew/bin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
}

# ── Phase 2: Brew packages ───────────────────────────────────
install_brew_packages() {
    info "Phase 2: Brew packages"
    local pkgs=(
        neovim tmux fzf htop jq ripgrep fd
        python3 curl wget git lazygit
    )
    local to_install=()
    for pkg in "${pkgs[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done
    if [ ${#to_install[@]} -gt 0 ]; then
        info "Installing: ${to_install[*]}"
        brew install "${to_install[@]}"
    fi
    ok "Brew packages ready"
}

# ── Phase 3: Oh-My-Zsh + plugins ─────────────────────────────
install_ohmyzsh() {
    info "Phase 3: Oh-My-Zsh + plugins"

    # Oh-My-Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh-My-Zsh already installed"
    else
        info "Installing Oh-My-Zsh"
        RUNZSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Powerlevel10k
    if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        ok "Powerlevel10k already installed"
    else
        info "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k"
    fi

    # zsh-autosuggestions
    if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        ok "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions"
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        ok "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting"
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    ok "Oh-My-Zsh + plugins ready"
}

# ── Phase 4: TPM (Tmux Plugin Manager) ───────────────────────
install_tpm() {
    info "Phase 4: TPM"
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        ok "TPM already installed"
        return
    fi
    git clone --depth=1 https://github.com/tmux-plugins/tpm \
        "$HOME/.tmux/plugins/tpm"
    ok "TPM installed"
}

# ── Phase 5: NVM + Node.js LTS + prettier ────────────────────
install_node() {
    info "Phase 5: NVM + Node.js"
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    if [ ! -d "$NVM_DIR" ]; then
        info "Installing NVM"
        PROFILE=/dev/null bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"
    fi

    # Source nvm for this session
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if ! has node; then
        info "Installing Node.js LTS"
        nvm install --lts
    fi
    ok "Node $(node --version)"

    if ! has prettier; then
        info "Installing prettier globally"
        npm install -g prettier
    fi
    ok "prettier ready"
}

# ── Phase 6: Python tools ────────────────────────────────────
install_python_tools() {
    info "Phase 6: Python tools"
    local pip_pkgs=(black debugpy)
    for pkg in "${pip_pkgs[@]}"; do
        if ! python3 -m pip show "$pkg" &>/dev/null; then
            info "pip install $pkg"
            python3 -m pip install --user --break-system-packages "$pkg" 2>/dev/null \
                || python3 -m pip install --user "$pkg"
        fi
    done
    ok "Python tools ready"
}

# ── Phase 7: Rust + stylua ───────────────────────────────────
install_rust_and_stylua() {
    info "Phase 7: Rust + stylua"
    if ! has cargo; then
        info "Installing Rust via rustup"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
    ok "Rust ready"

    if ! has stylua; then
        info "Installing stylua"
        cargo install stylua
    fi
    ok "stylua ready"
}

# ── Phase 8: Symlinks (install.sh) ───────────────────────────
run_install_script() {
    info "Phase 8: Symlinks"
    chmod +x "$REPO_DIR/install.sh"
    bash "$REPO_DIR/install.sh"
    ok "Symlinks created"
}

# ── Phase 9: Default shell → zsh ─────────────────────────────
set_default_shell() {
    info "Phase 9: Default shell"
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [ "$SHELL" = "$zsh_path" ]; then
        ok "zsh is already the default shell"
        return
    fi
    # Ensure brew zsh is in /etc/shells
    if ! grep -qF "$zsh_path" /etc/shells 2>/dev/null; then
        info "Adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    info "Changing default shell to zsh"
    chsh -s "$zsh_path"
    ok "Default shell set to zsh (takes effect on next login)"
}

# ── Phase 10: Headless plugin installs ────────────────────────
install_plugins_headless() {
    info "Phase 10: Headless plugin installs"

    # TPM plugins
    if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        info "Installing tmux plugins via TPM"
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM install had issues (may need a tmux session)"
    fi

    # Neovim: lazy sync + mason + treesitter
    info "Installing Neovim plugins (lazy.nvim sync)"
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

    info "Installing Mason packages"
    nvim --headless "+MasonInstall pyright ruff lua-language-server" +qa 2>/dev/null || true

    info "Installing Treesitter parsers"
    nvim --headless "+TSInstall python lua bash json yaml markdown javascript" +qa 2>/dev/null || true

    ok "Headless plugin installs done"
}

# ── Main ──────────────────────────────────────────────────────
main() {
    echo ""
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║      Dotfiles Bootstrap — macOS          ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo ""

    install_homebrew
    install_brew_packages
    install_ohmyzsh
    install_tpm
    install_node
    install_python_tools
    install_rust_and_stylua
    run_install_script
    set_default_shell
    install_plugins_headless

    echo ""
    ok "Bootstrap complete! Open a new terminal to start using zsh."
    echo ""
}

main "$@"
