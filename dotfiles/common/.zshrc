bindkey -v

export HISTSIZE="10000"
export SAVEHIST="10000"

export EDITOR="nvim"

if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-rc"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# Alias
alias -- ..='z ..'
alias -- ...='z ../..'
alias -- eza='eza --icons auto --color auto --git'
alias -- l='eza'
alias -- ls='eza'
alias -- la='eza -a'
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- lt='eza --tree'

alias -- gs='git status'
alias -- ga='git add'
alias -- gc='git commit'
alias -- gp='git push'
alias -- gl='git log'

alias -- c='clear'

alias -- microfetch='microfetch && echo'
alias -- se=sudoedit

alias -- sw='nh os switch'
alias -- upd='nh os switch --update'

alias -- v=nvim

# Save path when closing yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Plugins
fpath=(~/.config/zsh/completions/src $fpath)
# source ~/.config/zsh/autosuggestions/zsh-autosuggestions.zsh
# source ~/.config/zsh/syntax-highlighting/zsh-syntax-highlighting.zsh
# Gruvbox colors are now handled by ZSH_HIGHLIGHT_STYLES below
# source ~/.config/zsh/vi-mode/zsh-vi-mode.zsh

# Gruvbox Dark colors for zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[function]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[command]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#83a598'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[path]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#8ec07c'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#8ec07c'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#ebdbb2'

eval "$(starship init zsh)"
eval "$(zoxide init zsh )"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"

# TODO: find how configure atuin in vi insert and cmd mode in zsh
export ATUIN_NOBIND="true"
bindkey '^R' atuin-search-viins -i atuin
bindkey '^R' atuin-search-vicmd -i atuin

export PATH="/opt/homebrew/bin:~/.cargo/bin:$HOME/.npm-global/bin:/Applications/LibreOffice.app/Contents/MacOS:$PATH"

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
