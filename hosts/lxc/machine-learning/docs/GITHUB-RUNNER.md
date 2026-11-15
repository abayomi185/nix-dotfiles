# GitHub runner (auto-deploy)

`../github-runner.nix` runs a self-hosted GitHub Actions runner as a
home-manager user service. It serves `.github/workflows/deploy.yml`, which
deploys the hosts in `HOSTS` on every push to `main`.

This LXC runs Ubuntu with Nix and home-manager, not NixOS. Its
`nixosConfigurations.machine-learning` entry in `flake.nix` is commented out,
so the NixOS `services.github-runners` module is not used.

## Access

The runner runs as `ml`, so jobs use `~/.ssh/id_ed25519`:

- GitHub: the key already reads the private flake inputs (`nix-secrets`,
  `sonamesh`). Nix fetches inputs lazily, so deploying `video-recorder` and the
  knodes only needs `nix-secrets`.
- Targets: `ml@machine-learning` is in `nix-secrets/shared/authorized-keys.nix`,
  so it already has root SSH to every host that imports that list.
- New target host keys are trusted on first use (`accept-new`).

No age key is needed on the runner. sops-nix decrypts host secrets on each
target. The runner's own token is decrypted with ml's SSH key.

## One-time setup

1. Create a fine-grained PAT for `abayomi185/nix-dotfiles` with
   **Administration: read and write**. The runner uses it to register itself.
2. In `~/nix-secrets/.sops.yaml`, add ml's age recipient to the LXC rule:

   ```yaml
   - &ml age1a8apsk4zrzzh5uqxunlz38hlqpd76yjp38kewhk3rc8djrfa4sasu58jnl
   ```

   (Derived with `ssh-to-age < ~/.ssh/id_ed25519.pub` on this host.)
3. Store the PAT:

   ```sh
   cd ~/nix-secrets
   export SOPS_AGE_KEY=$(ssh-to-age -i ~/.ssh/id_ed25519 -private-key)
   echo '{}' > hosts/lxc/machine-learning/github-runner.enc.yaml
   sops encrypt -i hosts/lxc/machine-learning/github-runner.enc.yaml
   sops set hosts/lxc/machine-learning/github-runner.enc.yaml '["token"]' '"github_pat_..."'
   ```

   Commit, push, then `nix flake update nix-secrets` here.
4. In the repo settings (Actions → General), set fork PR workflows to
   **Require approval for all external contributors**. The repo is public, and
   a fork PR could otherwise target this runner.
5. On this host: `home-update`, then `systemctl --user status github-runner`.

To re-register, run `rm -rf ~/.local/share/github-runner` and restart the
service.
