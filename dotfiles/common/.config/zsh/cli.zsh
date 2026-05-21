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

# zinit plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

zinit as"null" wait"3" lucid for \
    Fakerr/git-recall \
    paulirish/git-open \
    paulirish/git-recent \
    davidosomething/git-my \
    make"PREFIX=$ZPFX install"  iwata/git-now \
    make"PREFIX=$ZPFX"          tj/git-extras

zi ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
zi load docker/compose

zi ice \
  as"program" \
  atclone"rm -f src/auto/config.cache; ./configure" \
  atpull"%atclone" \
  make \
  pick"src/vim"
zi light vim/vim

zi ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zi light tj/git-extras
