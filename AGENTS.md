# AGENTS.md - Coding Agent Guidelines for nix-dotfiles

## Project Overview

Nix Flakes-based dotfiles and infrastructure-as-code repository managing system
configurations for macOS (Darwin), NixOS servers, LXC containers, Kubernetes
nodes, a VPS, and a firewall VM. Primary language is Nix (~95%), with some
shell scripts, Lua, YAML, and JSON.

## Build / Rebuild Commands

```bash
# Format all Nix files (uses Alejandra)
nix fmt

# Check flake validity
nix flake check

# Update all flake inputs
nix flake update

# Update a single flake input
nix flake update <input-name>

# Rebuild macOS (Darwin) system
darwin-rebuild switch --flake .#Mac-Studio
darwin-rebuild switch --flake .#MacBook-Pro-14
update --flake .#MacBook-Pro-14 # Alias for darwin-rebuild switch --flake .#MacBook-Pro-14

# Rebuild NixOS system (run on the target host)
nixos-rebuild switch --flake .#<hostname>
# Hostnames: firewall, vps-arm64, knode1, knode2, knode3,
#            audio-share, kloadbalancer, network-share

# Rebuild home-manager standalone config
home-manager switch --flake .#yomi@A-MacBook-Pro-eth
home-manager switch --flake .#yomi@MacBook-Pro-14

# Evaluate a specific config without building (fast syntax/type check)
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel --no-build
nix eval .#darwinConfigurations.<hostname>.config.system.build.toplevel --no-build
```

## Linting

No CI pipeline or pre-commit hooks exist. Linters are available in the dev
environment (via Neovim) but have no project-level config files:

```bash
# Format Nix files
nix fmt

# Find dead code in Nix files
deadnix <file.nix>

# Lint Nix files for anti-patterns
statix check <file.nix>
statix fix <file.nix>
```

## Testing

There is no formal test suite. Validation is done by building/evaluating:

```bash
# Dry-run build to check for evaluation errors
nixos-rebuild dry-build --flake .#<hostname>

# Check the full flake (evaluates all outputs)
nix flake check
```

## Secrets Management

- **SOPS-nix** and **agenix** with **age** encryption
- Private secrets in separate repo: `git+ssh://git@github.com/abayomi185/nix-secrets.git`
- NEVER commit unencrypted secrets, `.env` files, or private keys
- Secret variables use `secret_` prefix in let bindings

## Commit Convention

Uses **Conventional Commits** with path-based scopes:

```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `chore`, `test`, `wip`, `feat!` (breaking)
Scopes match host/module paths: `firewall`, `vps`, `knode`, `mbp14`,
`lxc/network-share`, `lxc/load-balancer`, `home/dev/opencode`, `git`

Examples:
```
feat(lxc/network-share): update time machine max size config
fix(lxc/load-balancer): SSL certs with traefik and letsencrypt
chore: update secrets
```

## Repository Structure

```
hosts/{hostname}/          # Per-host configurations
  configuration.nix        # System-level config (users, nix settings, packages)
  home.nix                 # Home-manager config (imports shared modules)
  networking.nix           # Network config (NixOS servers)
  hardware-configuration.nix  # Auto-generated hardware config
modules/
  home-manager/{category}/ # Cross-platform user-level modules
  darwin/{category}/       # macOS-specific system modules
  nixos/{category}/        # NixOS-specific system modules
overlays/                  # Nix overlays (unstable, stable, custom pkgs)
pkgs/                      # Custom package definitions
```

## Code Style

### Formatter

All Nix files must be formatted with **Alejandra** (`nix fmt`). Always run
`nix fmt` before committing. Alejandra enforces 2-space indentation and all
whitespace rules.

### Function Arguments

Use the minimal arguments needed. Three patterns:

```nix
# No args needed - pure attribute set (simplest modules)
{
  programs.bat.enable = true;
}

# Single/few args - one line
{pkgs, ...}: {

# Multiple args - vertical listing
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
```

Note: Alejandra formats `{pkgs, ...}:` with no spaces inside braces.

### Imports

Registry files (`default.nix`) are flat attribute sets mapping names to imports:
```nix
{
  bat = import ./bat.nix;
  neovim = import ./neovim.nix;
}
```

Host configs import shared modules via `outputs` paths with category comments:
```nix
imports = [
  # Apps - See ../../modules/home-manager/apps/default.nix
  outputs.homeManagerModules.apps.bat
  outputs.homeManagerModules.apps.discord

  # Shell - See ../../modules/home-manager/shell/default.nix
  outputs.homeManagerModules.shell.git
];
```


### `with` Scope

Only use `with pkgs;` for package lists. Never use `with lib;` or `with config;`:
```nix
home.packages = with pkgs; [
  nodejs_22
  ripgrep
];
```


### Naming Conventions

| Context | Convention | Examples |
|---------|-----------|----------|
| Module attributes | `kebab-case` | `karabiner-elements`, `cargo-bins` |
| Let bindings | `camelCase` | `secretsPath`, `homeDir` |
| Secret variables | `snake_case` with `secret_` prefix | `secret_user_initialPassword` |
| Parameterized args | `camelCase` with `p` prefix | `pNodeId`, `pK3sRole` |
| Unused args | `_` prefix | `_prev` in overlays |

### Module Pattern

Each module handles one concern. Features are toggled by including/excluding
imports - not by boolean flags. Modules set `enable = true` directly:

```nix
{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [alejandra deadnix nil statix];
  };
}
```

Only use formal `options`/`config` separation when the module declares custom
options (rare - see `modules/home-manager/shell/zsh.nix` for an example).

### Comments

Use `#` line comments. Conventions:
- Section headers: `# ── Section Name ──────────────────────`
- Category comments in import lists: `# Apps - See ../../modules/.../default.nix`
- Markers: `# TODO:`, `# NOTE:`, `# WARN:`
- Commented-out imports are preserved for reference (disabled features)

### Error Handling

No explicit error handling (`assert`, `throw`, `tryEval`). Rely on Nix's
evaluation errors and the NixOS module system's type checking. Use
`lib.mkDefault` defensively in shared modules so hosts can override.

### Strings

Use `"..."` for short values. Use `''...''` for multi-line content (shell
scripts, config templates). Escape shell interpolation as `''${...}` inside
Nix multi-line strings.

### `inherit`

Use `inherit` only for forwarding arguments (e.g., `specialArgs`):
```nix
specialArgs = {inherit inputs outputs;};
```
