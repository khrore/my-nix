# Coloring Catppuccin theme
fish_config theme choose "Gruvbox Dark"

# disable fish hello
set -g fish_greeting ""

# ghostty integration
if set -q GHOSTTY_RESOURCES_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION no-rc
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

# Aliases
alias l eza
alias ls eza
alias la 'eza -a'
alias ll 'eza -l'
alias lla 'eza -la'
alias lt 'eza --tree'
alias eza 'eza --icons auto --color auto --git'

alias v nvim
alias vd 'nvim -d'

alias .. "cd .."
alias ... "cd ../.."

alias gs 'git status'
alias gc 'git commit'
alias gp 'git push'
alias ga 'git add'
alias gd 'git diff'
alias gl 'git log'

alias c clear

alias sw 'nh os switch'
alias rsw 'nixos-rebuild switch'

# enviroment variables
export NH_OS_FLAKE="$HOME/nixos"
export NIXOS_CONFIG="$HOME/nixos"
export PATH="$PATH:/usr/local/go/bin:/usr/local/nvim-linux-x86_64/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.venv/bin:$HOME/.npm-packages/bin"
export EDITOR="nvim"

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Interactive shell initialisation
fzf --fish | source
zoxide init fish | source
atuin init fish | source
starship init fish | source

# enable vi mode
function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert
end
