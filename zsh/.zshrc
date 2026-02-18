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

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Export TERM for 256-color support
export TERM="xterm-256color"

# Enable true color support for zsh
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
alias vim="nvim"
alias zshconfig="nvim ~/.zshrc"
alias p10kconfig="nvim ~/.p10k.zsh"

# Load Powerlevel10k configuration if available
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Configuración para mejorar tmux si lo usas
if [[ -n $TMUX ]]; then
  export TERM="tmux-256color"
fi

# Autocompletado (mejora visibilidad con colores)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

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
for _gcloud_dir in "$HOME/google-cloud-sdk" "/usr/lib/google-cloud-sdk" "/snap/google-cloud-cli/current"; do
    if [ -d "$_gcloud_dir" ]; then
        [ -f "$_gcloud_dir/path.zsh.inc" ] && . "$_gcloud_dir/path.zsh.inc"
        [ -f "$_gcloud_dir/completion.zsh.inc" ] && . "$_gcloud_dir/completion.zsh.inc"
        break
    fi
done
unset _gcloud_dir

# Linuxbrew
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
