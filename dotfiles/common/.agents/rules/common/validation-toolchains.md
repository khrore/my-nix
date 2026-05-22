<!-- markdownlint-disable MD013 -->

# Validation Toolchain Catalog

When code changes, identify touched file extensions and run the smallest applicable checks from this catalog. Prefer project-defined commands over generic commands.

## Command selection precedence

1. Use commands documented in repository files: `AGENTS.md`, `README*`, `CONTRIBUTING*`, `Makefile`, `justfile`, CI workflows, package scripts, or flake apps/checks.
1. Use pinned project environments before host tools: `nix develop`, `devbox shell`, `direnv exec`, `uv run`, `poetry run`, `pnpm exec`, `npm exec`, `cargo`, `go`, `dotnet`, `gradle`, etc.
1. Use commands scoped to touched files or packages when possible.
1. If no command can be identified, state that explicitly in the final response and classify it as `environment` or `scope-expanding`.

Do not install tools globally just to validate. Ask or use a pinned local environment instead.

## Extension-to-toolchain map

| Extensions / files | Formatter | Linter / static analysis | Type / compile / interpreter check | Scoped tests |
| --- | --- | --- | --- | --- |
| `.nix`, `flake.nix` | `nix fmt`, `nixpkgs-fmt`, `alejandra`, or `nixfmt` | `statix check`, `deadnix` | `nix flake check`, `nix eval`, `nix build` | host/package-specific `nix build` or flake checks |
| `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` | package script first, then `prettier --check`, `biome check`, or `deno fmt --check` | package script first, then `eslint`, `biome lint`, or `deno lint` | `tsc --noEmit`, framework build, or `node --check` for JS | package script, `vitest`, `jest`, `tsx --test`, `node --test`, or framework test runner |
| `.py`, `.pyi` | `ruff format --check`, `black --check`, or `autopep8 --diff` | `ruff check`, `flake8`, or `pylint` | `pyright`, `mypy`, or `python -m py_compile` | `pytest path::test`, `unittest`, or `uv run pytest` |
| `.rs` | `cargo fmt --check` | `cargo clippy -- -D warnings` | `cargo check` or `cargo build` | `cargo test <name>` or package-specific `cargo test -p` |
| `.go` | `gofmt -w`/`gofmt -l`, `go fmt` | `go vet`, `staticcheck` | `go test` compile phase or `go build` | `go test ./pkg -run TestName` |
| `.java` | `spotlessCheck`, `google-java-format --dry-run`, or IDE/Gradle/Maven formatter task | `checkstyle`, `pmd`, `spotbugs` | `mvn test-compile`, `gradle compileJava`, or `javac` | `mvn -Dtest=... test` or `gradle test --tests ...` |
| `.kt`, `.kts` | `ktlintFormat`/`ktlintCheck`, `spotlessCheck` | `ktlintCheck`, `detekt` | `gradle compileKotlin` | `gradle test --tests ...` |
| `.cs`, `.csproj`, `.sln` | `dotnet format --verify-no-changes` | `dotnet format analyzers`, Roslyn analyzers | `dotnet build --no-restore` | `dotnet test --filter ...` |
| `.cpp`, `.cc`, `.cxx`, `.c`, `.h`, `.hpp`, `.hxx` | `clang-format --dry-run --Werror` | `clang-tidy`, `cppcheck` | `cmake --build`, `make`, or compiler command | `ctest -R ...`, project-specific test binary |
| `.swift` | `swift-format lint` or `swiftformat --lint` | `swiftlint` | `swift build` | `swift test --filter ...` |
| `.dart` | `dart format --output=none --set-exit-if-changed .` | `dart analyze` | `dart compile` or `flutter analyze` | `dart test` or `flutter test` scoped target |
| `.php` | `php-cs-fixer fix --dry-run`, `pint --test`, or `phpcbf --dry-run` | `phpcs`, `phpstan`, `psalm` | `php -l`, Composer validation/autoload checks | `phpunit --filter ...` or `pest --filter ...` |
| `.pl`, `.pm`, `.t` | `perltidy -b -nst` or project formatter | `perlcritic` | `perl -c` | `prove -v path.t` |
| `.sh`, `.bash`, `.zsh` | `shfmt -d` | `shellcheck` | `bash -n`, `zsh -n` | `bats path.bats` or script-specific smoke test |
| `.json`, `.jsonc` | `prettier --check`, `biome check`, `jq empty` | schema validator when available | parser check (`jq empty`) | config-specific smoke test |
| `.yaml`, `.yml` | `prettier --check` or `yamlfmt -lint` | `yamllint` | schema validator when available | config-specific smoke test |
| `.md`, `.mdx` | `mdformat --check` first, or `prettier --check` when project-standard | `markdownlint-cli2` first, or `markdownlint` when project-standard | link/code-block check when configured | docs build or relevant examples |
| `.sql` | `sqlfmt --check` or `pg_format --check` | `sqlfluff lint` | database migration dry-run/typegen | migration or repository integration tests |
| `.html`, `.css`, `.scss`, `.vue`, `.svelte` | package script first, `prettier --check`, `biome check` | framework linter, `stylelint`, `eslint` | framework build or type check | component/unit/e2e test scoped to changed component |

## Final response evidence

Report every validation command run and its outcome. If a command was skipped, report why and classify the skip/failure using the project failure categories.
