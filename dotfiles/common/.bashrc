# bashrc

# Add this lines at the top of .bashrc:
source -- "$(blesh-share)"/ble.sh --noattach

# Vi mode
set -o vi

eval "$(atuin init bash)"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(fzf --bash)"

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
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

export PATH="/opt/homebrew/bin:~/.cargo/bin:$HOME/.npm-global/bin:/Applications/LibreOffice.app/Contents/MacOS:$PATH"

export EDITOR="nvim"

# Add this line at the end of .bashrc:
[[ ! ${BLE_VERSION-} ]] || ble-attach

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
