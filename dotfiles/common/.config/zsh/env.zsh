bindkey -v

export EDITOR="nvim"

export PATH="$HOME/.npm-global/bin:"\
"$HOME/.cargo/bin:"\
"$HOME/.bun/bin:"\
"$HOME/.local/bin:$PATH"

export HISTSIZE="10000"
export SAVEHIST="10000"

export NIXOS_CONFIG="$HOME/my-nix"

export NH_FLAKE="$HOME/my-nix"

if [[ "$OSTYPE" == darwin* ]]; then
  alias sw='nh darwin switch'
  alias upd='nh darwin switch --update'
else
  alias sw='nh os switch'
  alias upd='nh os switch --update'
fi

export NIX_BUILD_SHELL="bash"

export GOCACHE="$HOME/.gocache"

export POETRY_CERTIFICATES_INTERNAL_CERT="./certs/gosniias.crt"
