{
  lib,
  pkgs-unstable,
  mylib,
  system,
  ...
}:
let
  # Hyprland-specific tools (Linux only)
  linuxTools = lib.optionals (mylib.isLinux system) [
    pkgs-unstable.hyprls
    # pkgs-unstable.marksman
  ];
in
{
  home.packages =
    with pkgs-unstable;
    [
      # C/C++ stuff
      clang
      lldb

      # Nix
      nil
      nixfmt
      statix
      nixd

      # Lua
      lua-language-server
      luajit
      stylua
      luajitPackages.luacheck

      # Python
      python313
      ruff
      basedpyright
      python313Packages.debugpy

      # Bash
      bash-language-server
      shellcheck
      shfmt

      # Go
      go
      delve

      # Nushell
      nufmt

      # Fish
      fish-lsp

      # Markdown
      mdformat
      markdownlint-cli2
      marksman
      glow

      # Yaml
      yaml-language-server

      # HTML/CSS/JSON/ESLint
      vue-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      eslint

      # TypeScript and JavaScript
      vtsls
      vscode-js-debug
      typescript
      prettier
      prettierd
      biome
      nodejs
      bun

      # CMake
      cmake
      neocmakelsp
      cmake-format
      cmake-lint

      # Make
      gnumake
      checkmake

      # JSON
      formatjson5

      # General
      tree-sitter

      # Rust
      bacon
    ]
    ++ linuxTools;
}
