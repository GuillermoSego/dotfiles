#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║          WSL/Ubuntu Bootstrap — Full Dev Environment        ║
# ║     Idempotent: safe to re-run, skips what's installed      ║
# ╚══════════════════════════════════════════════════════════════╝

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Helpers ───────────────────────────────────────────────────
info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
err()   { printf '\033[1;31m[ERR]\033[0m   %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

# ── Phase 1: System packages (apt) ───────────────────────────
install_system_packages() {
    info "Phase 1: System packages"
    local pkgs=(
        zsh tmux fzf htop jq make gcc xclip unzip
        ripgrep fd-find
        python3 python3-pip python3-venv
        curl wget git
    )
    local to_install=()
    for pkg in "${pkgs[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done
    if [ ${#to_install[@]} -gt 0 ]; then
        info "Installing: ${to_install[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y -qq "${to_install[@]}"
    fi
    ok "System packages ready"
}

# ── Phase 2: Neovim (latest stable AppImage) ─────────────────
install_neovim() {
    info "Phase 2: Neovim"
    if has nvim; then
        ok "Neovim already installed: $(nvim --version | head -1)"
        return
    fi
    info "Installing Neovim (latest stable AppImage)"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/nvim.appimage" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
    chmod +x "$tmp/nvim.appimage"
    sudo mv "$tmp/nvim.appimage" /usr/local/bin/nvim
    rm -rf "$tmp"
    ok "Neovim installed: $(nvim --version | head -1)"
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

# ── Phase 8: lazygit ─────────────────────────────────────────
install_lazygit() {
    info "Phase 8: lazygit"
    if has lazygit; then
        ok "lazygit already installed"
        return
    fi
    local version
    version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | sed 's/^v//')"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/lazygit.tar.gz" \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp"
    sudo install "$tmp/lazygit" /usr/local/bin/lazygit
    rm -rf "$tmp"
    ok "lazygit v${version} installed"
}

# ── Phase 9: Symlinks (install.sh) ───────────────────────────
run_install_script() {
    info "Phase 9: Symlinks"
    chmod +x "$REPO_DIR/install.sh"
    bash "$REPO_DIR/install.sh"
    ok "Symlinks created"
}

# ── Phase 10: Default shell → zsh ────────────────────────────
set_default_shell() {
    info "Phase 10: Default shell"
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [ "$SHELL" = "$zsh_path" ]; then
        ok "zsh is already the default shell"
        return
    fi
    info "Changing default shell to zsh"
    chsh -s "$zsh_path"
    ok "Default shell set to zsh (takes effect on next login)"
}

# ── Phase 11: Headless plugin installs ────────────────────────
install_plugins_headless() {
    info "Phase 11: Headless plugin installs"

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
    echo "  ║     Dotfiles Bootstrap — WSL/Ubuntu      ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo ""

    install_system_packages
    install_neovim
    install_ohmyzsh
    install_tpm
    install_node
    install_python_tools
    install_rust_and_stylua
    install_lazygit
    run_install_script
    set_default_shell
    install_plugins_headless

    echo ""
    ok "Bootstrap complete! Open a new terminal to start using zsh."
    echo ""
}

main "$@"
