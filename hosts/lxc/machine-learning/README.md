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

Run Home Manager for this host

```bash
nix --extra-experimental-features "nix-command flakes" run nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake .#ml@machine-learning
# Optionally with home-manager backup
# nix --extra-experimental-features "nix-command flakes" run nixpkgs#home-manager -- --extra-experimental-features "nix-command flakes" switch --flake .#ml@machine-learning -b backup
```

llama-server notes live in `./docs/LLAMA.md`.

Current managed llama-server details:

- service: `systemctl --user status llama-server`
- bind: `0.0.0.0:9000`
- API key file: `~/.config/llama-server/api-keys`
- model presets: `./configs/llama-models.ini`

Rotate the API key on the host with:

```bash
umask 077
mkdir -p ~/.config/llama-server
openssl rand -base64 48 | tr -d '\n' > ~/.config/llama-server/api-keys.tmp
printf '\n' >> ~/.config/llama-server/api-keys.tmp
mv ~/.config/llama-server/api-keys.tmp ~/.config/llama-server/api-keys
chmod 600 ~/.config/llama-server/api-keys
systemctl --user restart llama-server
```
