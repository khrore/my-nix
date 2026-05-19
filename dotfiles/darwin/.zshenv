# nix-darwin runs compinit from /etc/zshrc before ~/.zshrc is read.
# Drop completion paths that compaudit rejects on this machine.
fpath=(${fpath:#/nix/var/nix/profiles/default/share/zsh*})
fpath=(${fpath:#/opt/homebrew/share/zsh/site-functions})
