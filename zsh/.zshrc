# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/jerry/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#------------------------------------------------------------------------------
# Set XDG Config Home
#------------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"

#------------------------------------------------------------------------------
# Alias
#------------------------------------------------------------------------------
if [ -f ~/aliasrc ]; then
    source ~/aliasrc
fi

#------------------------------------------------------------------------------
# Options
#------------------------------------------------------------------------------
if [ -f ~/optionrc ]; then
    source ~/optionrc
fi

#------------------------------------------------------------------------------
# Starship prompt
#------------------------------------------------------------------------------
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"


#------------------------------------------------------------------------------
# Shell Integration
#------------------------------------------------------------------------------
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"


#------------------------------------------------------------------------------
# ZSH Plugins
#------------------------------------------------------------------------------
source ~/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/plugins/fast-syntax-highlighting/F-Sy-H.plugin.zsh
source ~/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh
source ~/plugins/fzf-tab/fzf-tab.plugin.zsh

#------------------------------------------------------------------------------
# Keybindings
#------------------------------------------------------------------------------
# Load terminal key information
zmodload zsh/terminfo

# History substring search (Arrow keys)
# bindkey '^N' history-incremental-search-backward 
# bindkey '^P' history-incremental-search-forward

##FZF TAB
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
