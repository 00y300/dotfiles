# Set XDG Config Home
export XDG_CONFIG_HOME="$HOME/.config"

# OS-specific setups
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Homebrew initialization
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Miniconda initialization (using correct path)
    __conda_setup="$('/opt/homebrew/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "/opt/homebrew/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/bin:$PATH"
    fi
    unset __conda_setup

    # Additional macOS environment setups
    export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"
    source ~/.asdf/plugins/java/set-java-home.zsh

elif grep -q "ID=arch" /etc/os-release; then
    # Arch Linux specific setup
    __conda_setup="$(/opt/miniconda3/bin/conda 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
    unset __conda_setup

    # Arch Linux environment setups (CUDA, GTK, Wayland, etc.)
    export PATH="/usr/local/cuda-12.4/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH"
    export GTK_THEME="Adwaita:dark"
    export ELECTRON_OZONE_PLATFORM_HINT="wayland"
else
    echo "Unsupported OS"
fi

# Consolidated PATH updates
export PATH="$HOME/.asdf/installs/ruby/3.3.5/bin:$HOME/.local/bin:$PATH"

# Zinit plugin manager setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load Starship prompt and set the custom config path
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light sharkdp/bat
zinit light jeffreytse/zsh-vi-mode

# Snippets via Zinit
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::asdf

# Load completions
autoload -Uz compinit && compinit

# Zinit command replay
zinit cdreplay -q

# Keybindings
bindkey -e
# bindkey '^u' history-search-backward
# bindkey '^d' history-search-forward
bindkey '^[w' kill-region

# History settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# FZF-Tab configuration
zstyle ':fzf-tab:complete:*' fzf-preview 'bat --style=numbers --color=always --line-range=:500 $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='colorls'
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Disable OpenSSL legacy mode for cryptography
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# Editor setup: Prefer Neovim, fallback to Vim or Vi
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
elif command -v vi >/dev/null 2>&1; then
  export EDITOR="vi"
else
  echo "No suitable editor found. Please install nvim, vim, or vi."
fi
