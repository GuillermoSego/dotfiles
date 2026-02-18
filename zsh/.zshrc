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
# Portable conda detection using $HOME instead of hardcoded paths
__conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Google Cloud SDK
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# Homebrew (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
