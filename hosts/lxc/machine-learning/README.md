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

Expose llama.cpp via the VPS

```bash
export LLAMA_API_KEY='<shared-token>'

llama-server \
  --host 0.0.0.0 \
  --port 8080 \
  --model /path/to/qwen.gguf \
  --api-key "$LLAMA_API_KEY"
```

The VPS Traefik config proxies `https://llama.${MEDIA_DOMAIN_NAME}` to
`http://10.0.7.250:8080`, so your friend can use the shared bearer token
against the public llama.cpp endpoint.
