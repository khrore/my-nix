_zsh_config_dir=${${(%):-%x}:A:h}

source "$_zsh_config_dir/yazi.zsh"
source "$_zsh_config_dir/alias.zsh"
source "$_zsh_config_dir/cli.zsh"

unset _zsh_config_dir
