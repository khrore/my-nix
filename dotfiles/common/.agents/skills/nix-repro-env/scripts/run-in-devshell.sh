#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "usage: $0 <flake-ref> <devshell-attr|default> -- <command...>" >&2
  exit 1
fi

flake_ref="$1"
shell_attr="$2"
shift 2

if [[ "$1" != "--" ]]; then
  echo "error: expected -- before command" >&2
  exit 1
fi
shift

if [[ $# -eq 0 ]]; then
  echo "error: missing command to run" >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is not installed or not on PATH" >&2
  exit 1
fi

if [[ "$shell_attr" == "default" ]]; then
  target="$flake_ref"
  report_attr="default"
else
  target="${flake_ref}#${shell_attr}"
  report_attr="$shell_attr"
fi

echo "flake_ref=$flake_ref"
echo "devshell_attr=$report_attr"
echo "command=$*"

exec nix develop "$target" -c "$@"
