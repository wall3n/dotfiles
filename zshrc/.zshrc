#!/usr/bin/env zsh
# Uncomment for debuf with `zprof`
# zmodload zsh/zprof

# ZSH Ops
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FCNTL_LOCK
setopt +o nomatch
# setopt autopushd

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Start Starship
eval "$(starship init zsh)"

# Change the directory of the Starship config
export STARSHIP_CONFIG=~/.dotfiles/starship/starship.toml

# Async mode for autocompletion
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_HIGHLIGHT_MAXLENGTH=300

source "$DOTFILES_PATH/zshrc/init.sh"

# Cmake
export PATH="/Applications/CMake.app/Contents/bin":/opt/local/bin:/opt/local/sbin:$PATH

# fnm
export PATH="/Users/franmoreno/Library/Application Support/fnm:$PATH"
eval "`fnm env`"
eval "$(fzf --zsh)"
export PATH="/opt/homebrew/opt/bison/bin:$PATH"
