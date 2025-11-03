#!/usr/bin/env zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

export LANG=es_ES.UTF-8

# Start Starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.dotfiles/starship/starship.toml

source "/Users/franmoreno/.dotfiles/zshrc/init.sh"

# Cmake
export PATH="/Applications/CMake.app/Contents/bin":/opt/local/bin:/opt/local/sbin:$PATH

# fnm
export PATH="/Users/franmoreno/Library/Application Support/fnm:$PATH"
eval "`fnm env`"
eval "$(fzf --zsh)"
export PATH="/opt/homebrew/opt/bison/bin:$PATH"

# Zoxide
eval "$(zoxide init zsh)"
compinit

# Fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# sdkman - Java Version Manager
source "$HOME/.sdkman/bin/sdkman-init.sh"

export XDG_CONFIG_HOME="/Users/franmoreno/.config"
