# machine-learning

ylac: Yomi's local AI Cloud/Compute

Install nix on Ubuntu/Debian

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

Clone this repository

```bash
git clone git@github.com:abayomi185/nix-dotfiles.git
```

Run home manager for this host

```bash
nix --extra-experimental-features "nix-command flakes" run nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake .#ml@machine-learning
# Optionally with home-manager backup
# nix --extra-experimental-features "nix-command flakes" run nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake .#ml@machine-learning -b backup
```
