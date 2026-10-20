_zsh_config_dir="$HOME/.config/zsh"

# zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

source "$_zsh_config_dir/cli.zsh"

source "$_zsh_config_dir/yazi.zsh"
source "$_zsh_config_dir/alias.zsh"
source "$_zsh_config_dir/terminal.zsh"
source "$_zsh_config_dir/env.zsh"
source "$_zsh_config_dir/platform.zsh"

# Vim movement applies only while selecting completion results.
zmodload zsh/complist
zstyle ':completion:*' menu select
bindkey -M menuselect 'h' backward-char
bindkey -M menuselect 'j' down-line-or-history
bindkey -M menuselect 'k' up-line-or-history
bindkey -M menuselect 'l' forward-char
bindkey -M menuselect '^J' down-line-or-history
bindkey -M menuselect '^K' up-line-or-history

unset _zsh_config_dir
