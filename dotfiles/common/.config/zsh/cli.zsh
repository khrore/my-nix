eval "$(starship init zsh)"
eval "$(zoxide init zsh )"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
