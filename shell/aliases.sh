# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ls="lsd"
alias ll="ls -l"
alias la="ls -la"
alias ~="cd ~"
alias dotfiles='cd $DOTFILES_PATH'
alias projects='cd $PROJECTSROOT'
alias cat="/usr/bin/bat"
alias vi="/usr/bin/nvim"
alias vim="/usr/bin/nvim"

# Git
alias gaa="git add -A"
alias gc='$DOTLY_PATH/bin/dot git commit'
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd='$DOTLY_PATH/bin/dot git pretty-diff'
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"
alias gl='$DOTLY_PATH/bin/dot git pretty-log'

# Utils
alias k='kill -9'
alias i.='(idea $PWD &>/dev/null &)'
alias c.='(code $PWD &>/dev/null &)'
alias o.='open .'
alias up='dot package update_all'

# Editors
alias idea='~/JetBrains/idea'

 # Custom scripts
 alias key='~/.dotfiles/bin/key.sh'
 alias docker-login='~/.dotfiles/bin/docker-login.sh'
 alias aliaser='~/.dotfiles/bin/aliaser.sh' # Custom scripts
 alias key='~/.dotfiles/bin/key.sh'
 alias docker-login='alias aliaser='~:wq
