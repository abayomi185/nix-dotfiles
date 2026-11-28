# GitHub Actions runner for .github/workflows/deploy.yml.
#
# This host is Ubuntu + home-manager, not NixOS, so the NixOS
# `services.github-runners` module can't be used. This is a minimal user
# service equivalent. It runs as `ml`, so jobs reuse ml's SSH key (GitHub
# access for private flake inputs, root on hosts via shared authorized keys).
# Setup: see ./docs/GITHUB-RUNNER.md
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  tokenSecret = "github-runner-token";
  runnerRoot = "${config.home.homeDirectory}/.local/share/github-runner";

  # Registers once; the runner keeps its credentials in RUNNER_ROOT afterwards.
  # To re-register, delete RUNNER_ROOT and restart the service.
  configure = pkgs.writeShellScript "github-runner-configure" ''
    set -eu
    [ -e "$RUNNER_ROOT/.runner" ] && exit 0
    mkdir -p "$RUNNER_ROOT"
    ${pkgs.github-runner}/bin/Runner.Listener configure \
      --unattended \
      --disableupdate \
      --replace \
      --url https://github.com/abayomi185/nix-dotfiles \
      --name machine-learning \
      --labels nixos-deploy \
      --work "$RUNNER_ROOT/_work" \
      --pat "$(<${config.sops.secrets.${tokenSecret}.path})"
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    secrets.${tokenSecret} = {
      sopsFile = "${inputs.nix-secrets}/hosts/lxc/machine-learning/github-runner.enc.yaml";
      key = "token";
    };
  };

  systemd.user.services.github-runner = {
    Unit = {
      Description = "GitHub Actions runner (nix-dotfiles deploy)";
      After = ["network-online.target" "sops-nix.service"];
      Wants = ["sops-nix.service"];
    };
    Service = {
      Environment = [
        "RUNNER_ROOT=${runnerRoot}"
        "PATH=${lib.makeBinPath (with pkgs; [
          bash
          coreutils
          git
          gnutar
          gzip
          nixos-rebuild-ng
          openssh
          config.nix.package
        ])}"
      ];
      ExecStartPre = "${configure}";
      ExecStart = "${pkgs.github-runner}/bin/Runner.Listener run --startuptype service";
      Restart = "on-failure";
      RestartSec = 30;
    };
    Install.WantedBy = ["default.target"];
  };
}
