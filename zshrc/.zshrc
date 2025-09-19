#!/usr/bin/env zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

# Uncomment for debuf with `zprof`
# zmodload zsh/zprof

# Start Starship
eval "$(starship init zsh)"

export LANG=es_ES.UTF-8

# Change the directory of the Starship config
export STARSHIP_CONFIG=~/.dotfiles/starship/starship.toml

source "/Users/franmoreno/.dotfiles/zshrc/init.sh"

# Cmake
export PATH="/Applications/CMake.app/Contents/bin":/opt/local/bin:/opt/local/sbin:$PATH

# fnm
export PATH="/Users/franmoreno/Library/Application Support/fnm:$PATH"
eval "`fnm env`"
eval "$(fzf --zsh)"
export PATH="/opt/homebrew/opt/bison/bin:$PATH"




