# Enable aliases to be sudo’ed
alias sudo='sudo '

# Dir
alias ..="cd .."
alias ...="cd ../.."

# Ls
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"


# Dotfiles
alias dotfiles='cd $DOTFILES_PATH'

# Git
alias gadd="git add"
alias gc='git commit -m'
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gdiff='git diff'
alias gst="git status "
alias gps="git push"
alias gpl="git pull"
alias gb="git branch"
alias gl='git log'

# Utils
alias k='kill -9'
alias maude='~/Desktop/AED/Maude/maude.arm64'
