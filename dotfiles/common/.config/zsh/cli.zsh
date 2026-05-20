eval "$(starship init zsh)"
eval "$(zoxide init zsh )"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# calapace
autoload -U compinit && compinit
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# gruvbox theme
export LS_COLORS=$(vivid generate gruvbox-dark)
