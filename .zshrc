# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

case "$OSTYPE" in
  darwin*)
    # ...
    alias rm='trash -F'
    export GIT_EDITOR=code\ --wait
    export EDITOR="code"
    export SSH_AUTH_SOCK=~/.1password/agent.sock
  ;;
  linux*)
    # ...
    alias bat="batcat"
    export EDITOR="vim"
    touch ~/.dotenv
  ;;
  dragonfly*|freebsd*|netbsd*|openbsd*)
    # ...
  ;;
esac

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# in ~/.zshrc, before Oh My Zsh is sourced:
ZSH_DOTENV_FILE=~/.dotenv
ZSH_DOTENV_PROMPT=false

# If you come from bash you might have to change your $PATH.
export BAT_CONFIG_PATH=$HOME/.config/bat/config
export GOPATH=$HOME/go
export MYVIMRC=$HOME/.vim/vimrc
export PAGER="less"
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/python/libexec/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$GOPATH/bin:$PATH
export TERM="xterm-256color"
export VISUAL="vim"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

autoload -U +X bashcompinit && bashcompinit

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

complete -o nospace -C /usr/local/bin/vault vault

eval "$(fasd --init auto)"

# fasd & fzf - jump using `fasd` if argument is given, filter output of `fasd`
# using `fzf` otherwise.
unalias j 2>/dev/null
j() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# fasd & fzf - use $EDITOR to edit file. Pick best matched file using `fasd`
# if argument given, else use `fzf` to filter `fasd` output.
unalias e 2>/dev/null
e() {
    [ $# -gt 0 ] && fasd -f -e ${EDITOR} "$*" && return
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && ${EDITOR} "${file}" || return 1
}

# fasd & fzf - open finder. If argument given, use `fasd` to pick the best match
# else use `fzf` to select from `fasd` results.
unalias o 2>/dev/null
o() {
    [ $# -gt 0 ] && fasd -a -e open "$*" && return
    local res
    res="$(fasd -Rla "$1" | fzf -1 -0 --no-sort +m)"
    if [[ -d "${res}" ]]; then
       open "${res}"
    else
       open "$(dirname "$res")"
    fi
}

complete -o nospace -C /usr/local/bin/terraform terraform

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Aliases
source $HOME/.aliases

if [ $(command -v direnv) ]; then
  eval "$(direnv hook zsh)"
fi


# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update
else
  source ~/.zplug/init.zsh
fi

# Supports oh-my-zsh plugins and the like
zplug "plugins/aws",                       from:oh-my-zsh
zplug "plugins/brew",                      from:oh-my-zsh
zplug "plugins/colored-man-pages",         from:oh-my-zsh
zplug "plugins/docker",                    from:oh-my-zsh
zplug "plugins/docker-compose",            from:oh-my-zsh
zplug "plugins/dotenv",                    from:oh-my-zsh
zplug "plugins/fzf",                       from:oh-my-zsh
zplug "plugins/git",                       from:oh-my-zsh
zplug "plugins/macos",                     from:oh-my-zsh
zplug "plugins/terraform",                 from:oh-my-zsh
zplug "plugins/virtualenv",                from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions",     defer:2
zplug "zsh-users/zsh-completions",         defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "Aloxaf/fzf-tab",                    defer:3
zplug "romkatv/powerlevel10k",             as:theme
zplug "robbyrussell/oh-my-zsh",            as:plugin, use:"lib/*.zsh"
zplug 'zplug/zplug',                       hook-build:'zplug --self-manage'

# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load

complete -o nospace -C /usr/local/bin/vault vault

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.dotenv

eval "$(navi widget zsh)"

############## BEGIN LOKI-SHELL #####################

# NOTE when changing the Loki URL, also remember to change the promtail config: ~/.loki-shell/config/promtail-logging-config.yaml

export LOKI_URL="http://localhost:4100"

[ -f ~/.loki-shell/shell/loki-shell.zsh ] && source ~/.loki-shell/shell/loki-shell.zsh

############## END LOKI-SHELL   #####################

# exa aliases
alias ls='exa'                                                         # ls
alias l='exa -lbF --git'                                               # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGF --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
alias lS='exa -1'                                                      # one column, just names
alias lt='exa --tree --level=2'                                        # tree
