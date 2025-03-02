set -o vi
bindkey -M viins 'jk' vi-cmd-mode

export VISUAL="vim"
export EDITOR="$VISUAL"

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lal='lla'