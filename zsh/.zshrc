# Enable Powerlevel10k instant prompt. Keep this near the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set Powerlevel10k as the theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins to load
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Plugin config (must be set BEFORE sourcing oh-my-zsh)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# True color support (let terminal/tmux handle TERM — only set COLORTERM)
export COLORTERM="truecolor"

# Set language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Aliases for common tasks
alias ll="ls -lah"
alias la="ls -A"
alias vim="nvim"
alias v="nvim"
alias zshconfig="nvim ~/.zshrc"
alias p10kconfig="nvim ~/.p10k.zsh"
alias lg="lazygit"

# Git aliases (complementan los de oh-my-zsh git plugin)
alias ga="git add"
alias gap="git add -p"
alias gcm="git commit -m"
alias gco="git checkout"
alias gst="git status -sb"
alias glog="git log --oneline --graph --decorate -15"
alias gd="git diff"
alias gds="git diff --staged"
alias gp="git push"
alias gpl="git pull --rebase"

# Load Powerlevel10k configuration if available
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Configuración para mejorar tmux si lo usas
if [[ -n $TMUX ]]; then
  export TERM="tmux-256color"
fi

# Path additions
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# >>> conda initialize >>>
# Portable conda detection: searches common install locations
for _conda_prefix in "$HOME/anaconda3" "$HOME/miniconda3" "/opt/conda"; do
    if [ -x "$_conda_prefix/bin/conda" ]; then
        __conda_setup="$("$_conda_prefix/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$_conda_prefix/etc/profile.d/conda.sh" ]; then
                . "$_conda_prefix/etc/profile.d/conda.sh"
            else
                export PATH="$_conda_prefix/bin:$PATH"
            fi
        fi
        unset __conda_setup
        break
    fi
done
unset _conda_prefix
# <<< conda initialize <<<

# Google Cloud SDK — portable path detection
for _gcloud_dir in "$HOME/google-cloud-sdk" "$HOME/Downloads/google-cloud-sdk" "/usr/lib/google-cloud-sdk"; do
    if [ -d "$_gcloud_dir" ]; then
        [ -f "$_gcloud_dir/path.zsh.inc" ] && . "$_gcloud_dir/path.zsh.inc"
        [ -f "$_gcloud_dir/completion.zsh.inc" ] && . "$_gcloud_dir/completion.zsh.inc"
        break
    fi
done
unset _gcloud_dir

# Homebrew (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# NVM — lazy loading (saves ~200ms on shell startup)
export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
    unset -f nvm node npm npx yarn pnpm 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
for _cmd in nvm node npm npx yarn pnpm; do
    eval "${_cmd}() { _nvm_lazy_load; ${_cmd} \"\$@\"; }"
done
unset _cmd
