
umask 002

# disable terminal ^q/^s
stty stop undef

eval $(dircolors)
export SYSTEMD_PAGER=

export KB=1024.0
export MB=1048576.0
export GB=1073741824.0

export REPORTTIME=30

[[ -x /usr/bin/lesspipe ]] && eval $(/usr/bin/lesspipe)

[[ -f ~/.cargo/env ]] && source ~/.cargo/env

autoload run-help

# recursive grep, in case no rg
rgr () { grep --color=auto -irn \
    --exclude='*,v'            \
    --exclude='*.swp'          \
    --exclude='*.swo'          \
    --exclude='*.pyc'          \
    --exclude-dir='.hg'        \
    --exclude-dir='.git'       \
    "$@" . }

# ps grep
psg() { ps axu | (read line; echo $line; grep -i "$@"|grep -v "grep -i $@") }

# cd into the parent matching the pattern
c.. () { [[ "$1" == "" ]] && return; orig=$(pwd); while true; do old=$(pwd); cd .. ; if [[ ! "$(pwd)" =~ "$1" ]]; then cd $orig; cd $old; return; fi; done }

# cd into the git toplevel
.g () { d=$(git rev-parse --show-toplevel) && cd $d }

# fixes paste
reset-paste () { printf "\e[?2004l" }

# sudo without args = interactive
sudo () {
    if [[ "$#" == 0 || ( "$#" == 1 && "$1" == "-i" ) ]]; then
        /usr/bin/sudo $SHELL
    else
        /usr/bin/sudo "$@"
    fi
}

# 0 if command exists
have_command () {
  command -v "$1" >/dev/null 2>&1 && return 0
  return 1
}

# plugins
if [[ -f ~/.zplug/init.zsh ]]; then
    source ~/.zplug/init.zsh
    zplug "oconnor663/zsh-sensible"
    zplug "zsh-users/zsh-completions"
    zplug "agkozak/zsh-z"
    zplug "plugins/ssh-agent", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    if ! zplug check --verbose; then
        echo -n "Install zplug plugins? [y/n]: "
        if read -q; then
          echo; zplug install
        fi
    fi
    zplug load
fi

# key bindings
bindkey -e
bindkey "^[Od" backward-word
bindkey "^[Oc" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[OD" backward-word
bindkey "^[OC" forward-word
bindkey '^F' accept-and-menu-complete
bindkey "^Q" push-line-or-edit


# completion
#
# compinit
# zstyle ':completion:*:*' menu select=1
# zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
#     /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin


# pager
export PAGER=less
have_command bat && PAGER=bat

# grep
GREP=grep
have_command rg && GREP=rg

# editor
export EDITOR
if have_command nvim; then
  EDITOR=nvim
elif have_command vim ; then
  EDITOR=vim
elif have_command vi; then
  EDITOR=vi
fi

# aliases
alias -g L='2>&1 |'$PAGER
alias -g LL='|'$PAGER
alias -g H='|head'
alias -g T='|tail'
alias -g G='2>&1|'$GREP
alias -g GG='|'$GREP

alias l=$PAGER
alias t='tail'
alias h='head'
alias e=$EDITOR

alias dig='dig +nostats +noquestion +nocmd +nocomments'

alias apl=ansible-playbook
alias an=ansible

alias gs='git status -uall --renames --short'
alias gsu='git status -uno --renames --short'
alias gd='git diff'
alias gl='git lg'
alias gco='git checkout'
alias gcane='git commit --amend --no-edit --date=now'
alias gcanepf='git commit --amend --no-edit --date=now && git push --force'
alias gaaap='git add -A && git commit --amend --no-edit --date=now && git push --force'
alias tis='tig status'

alias k=kubectl

have_command fdfind && alias fd=/usr/bin/fdfind

# opts
setopt autocd
setopt autolist
setopt noclobber
setopt extendedglob
setopt globdots
setopt autopushd
setopt incappendhistory

# fzf
for dir in /usr/share/fzf /usr/share/fzf/shell /usr/share/doc/fzf/examples; do
    [[ -f $dir/completion.zsh ]] && source $dir/completion.zsh
    [[ -f $dir/key-bindings.zsh ]] && source $dir/key-bindings.zsh
done


# history
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..|cd -|pushd|popd)"
export HISTSIZE=999999
mkdir -p ~/.local/state/zsh
export HISTFILE=~/.local/state/zsh/history-$(date +%Y%m%d%H%M%S)-$$

have_command atuin && eval "$(atuin init --disable-up-arrow zsh)"

# prompt
setopt promptsubst
PR_RED='%{%F{red}%B%}'
PR_GREEN='%{%F{green}%B%}'
PR_YELLOW='%{%F{yellow}%B%}'
PR_BLUE='%{%F{cyan}%B%}'
PR_RESET='%f%b%k'
PRB_BLUE='%K{blue}%B'
PRB_GREEN='%K{green}%B'
PRB_RED='%K{red}%B'
PRB_YELLOW='%K{yellow}%B'

precmd () {
    if [ -n "$WINDOW" ]; then
        PR_SCREEN="$PR_SEP${PRB_YELLOW}S:$WINDOW"
    else
        PR_SCREEN=""
    fi;

    j=$(jobs|wc -l)
    if [ "$j" != "0" ]; then
        PR_JOBS="${PRB_YELLOW} J:$j ${PR_RESET}"
    else
        PR_JOBS=""
    fi

    git_branch=$(git branch 2>/dev/null|awk '/^\*/ { print $2 }')
    if [[ $git_branch != "" ]]; then
        PR_GIT=" ${PR_YELLOW}G:$git_branch"
    else
        PR_GIT=""
    fi

    if [[ -n "$AWS_OKTA_PROFILE" ]]; then
        PR_AWS=" ${PR_YELLOW}A:$AWS_OKTA_PROFILE"
    else
        PR_AWS=""
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        PR_VENV="${PRB_BLUE} V:${VIRTUAL_ENV##$HOME/} ${PR_RESET}"
    else
        PR_VENV=""
    fi

    PS1="$PS1L1
$PS1L2"

    echo -ne ''
}

    PS1L1='${PRB_BLUE} %n@%m $PRB_GREEN %D{%T} $PR_RESET$PR_VENV$PR_SCREEN$PR_JOBS$PR_GIT$PR_AWS${PR_RESET} %B%~$PR_RESET'

    PS1L2='\
${PRB_BLUE} %! \
%(?..$PRB_RED %? )\
$PR_RESET%B %# $PR_RESET'

export PS2="${PR_RED}[$PR_GREEN%_${PR_RED}]$PR_RESET> "

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
