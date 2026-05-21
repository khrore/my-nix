#!/usr/bin/env bash
set -euo pipefail

flake_ref="${1:-.}"
selected_attr="${2:-}"

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is not installed or not on PATH" >&2
  exit 1
fi

system="$(nix eval --impure --raw --expr builtins.currentSystem)"

printf 'flake_ref=%s\n' "$flake_ref"
printf 'system=%s\n' "$system"

if [[ -n "$selected_attr" ]]; then
  printf 'selected_attr=%s\n' "$selected_attr"
fi

if [[ "$flake_ref" == "." || "$flake_ref" == /* ]]; then
  repo_path="$flake_ref"
  if [[ "$repo_path" == "." ]]; then
    repo_path="$PWD"
  fi

  if [[ -f "$repo_path/flake.lock" ]]; then
    echo "flake_lock=present"
  else
    echo "flake_lock=missing"
  fi

  if command -v git >/dev/null 2>&1 && git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ -n "$(git -C "$repo_path" status --short 2>/dev/null)" ]]; then
      echo "git_tree=dirty"
    else
      echo "git_tree=clean"
    fi
  fi
else
  echo "flake_lock=unknown"
fi
