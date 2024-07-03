umask 022

export PATH="$PATH:/snap/bin:~/.local/bin:~/.cargo/bin"
export LD_LIBRARY_PATH=~/.local/lib

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
