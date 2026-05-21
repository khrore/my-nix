#!/usr/bin/env bash
set -euo pipefail

flake_ref="${1:-.}"

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is not installed or not on PATH" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required" >&2
  exit 1
fi

tmp_root="${TMPDIR:-/tmp}"
if [[ ! -d "$tmp_root" || ! -w "$tmp_root" ]]; then
  tmp_root="/tmp"
fi
json_output="$(mktemp "${tmp_root%/}/nix-repro-env.XXXXXX")"
trap 'rm -f "$json_output"' EXIT

if ! nix flake show --json "$flake_ref" >"$json_output"; then
  echo "error: failed to inspect flake outputs for $flake_ref" >&2
  exit 1
fi

python3 - "$json_output" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)
labels = {"packages", "apps", "devShells", "checks", "nixosConfigurations", "darwinConfigurations"}
groups = {key: [] for key in labels}

def walk(node, path):
    if isinstance(node, dict):
        node_type = node.get("type")
        if len(path) > 1 and path[0] in labels and node_type in {"package", "app", "derivation", "nixos-configuration", "darwin-configuration", "unknown"}:
            groups[path[0]].append(".".join(path))
        for key, value in node.items():
            if key in {"type", "description"}:
                continue
            walk(value, path + [key])

walk(data, [])

for key in sorted(groups):
    values = sorted(set(groups[key]))
    print(f"{key}:")
    if values:
        for value in values:
            print(f"  - {value}")
    else:
        print("  - <none>")
PY
