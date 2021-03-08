# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# in ~/.zshrc, before Oh My Zsh is sourced:
ZSH_DOTENV_FILE=~/.dotenv
ZSH_DOTENV_PROMPT=false
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export GOPATH=$HOME/go
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/python/libexec/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$GOPATH/bin:$PATH
export TERM="xterm-256color"
export EDITOR="vim"
export MYVIMRC="~/.vim/vimrc"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

autoload -U +X bashcompinit && bashcompinit
autoload -U compinit && compinit

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

# Zplug Section
if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/zplug/zplug.git ~/.zplug
fi

source ~/.zplug/init.zsh

# Supports oh-my-zsh plugins and the like
zplug "plugins/aws",                       from:oh-my-zsh
zplug "plugins/brew",                      from:oh-my-zsh
zplug "plugins/colored-man-pages",         from:oh-my-zsh
zplug "plugins/docker",                    from:oh-my-zsh
zplug "plugins/docker-compose",            from:oh-my-zsh
zplug "plugins/dotenv",                    from:oh-my-zsh
zplug "plugins/fzf",                       from:oh-my-zsh
zplug "plugins/git",                       from:oh-my-zsh
zplug "plugins/osx",                       from:oh-my-zsh
zplug "plugins/terraform",                 from:oh-my-zsh
zplug "plugins/virtualenv",                from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions",     defer:2
zplug "zsh-users/zsh-completions",         defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "Aloxaf/fzf-tab",                    defer:3
zplug "romkatv/powerlevel10k",             as:theme
zplug "robbyrussell/oh-my-zsh",            as:plugin, use:"lib/*.zsh"

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
