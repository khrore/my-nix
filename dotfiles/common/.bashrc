# bashrc

export PATH="/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:/Applications/LibreOffice.app/Contents/MacOS:$PATH"

if command -v blesh-share >/dev/null 2>&1; then
  source -- "$(blesh-share)"/ble.sh --noattach
fi

# Vi mode
set -o vi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias -- ..='z ..'
  alias -- ...='z ../..'
else
  alias -- ..='cd ..'
  alias -- ...='cd ../..'
fi
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# Alias
if command -v eza >/dev/null 2>&1; then
  alias -- eza='eza --icons auto --color auto --git'
  alias -- l='eza'
  alias -- ls='eza'
  alias -- la='eza -a'
  alias -- ll='eza -l'
  alias -- lla='eza -la'
  alias -- lt='eza --tree'
fi

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

export EDITOR="nvim"
export NIX_BUILD_SHELL="zsh"

# Add this line at the end of .bashrc:
[[ ! ${BLE_VERSION-} ]] || ble-attach

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
