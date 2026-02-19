# NixOS Firewall VM - Main configuration
# Migrated from OPNsense (internal.yomitosh.media)
{
  config,
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./nftables.nix
    ./dns.nix
    ./dhcp.nix
    ./wireguard.nix
    ./services.nix
  ];

  # ── Nix settings ────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # ── System ──────────────────────────────────────────────────────────────
  system.stateVersion = "25.11";
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Packages ────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    neovim
    htop
    tcpdump
    nftables
    ethtool
    bridge-utils
    wireguard-tools
    dig
    traceroute
    iperf3
  ];

  # ── Users ───────────────────────────────────────────────────────────────
  users.users.yom = {
    isNormalUser = true;
    description = "Yomi";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      # Decoded from OPNsense base64: ssh-ed25519 key
      # Add authorized keys here for SSH access to the firewall VM
    ];
  };

  # Allow wheel group to use sudo without password (convenience for admin)
  security.sudo.wheelNeedsPassword = false;

  # ── Sops-nix defaults ──────────────────────────────────────────────────
  sops.defaultSopsFormat = "yaml";

  # ── Console ─────────────────────────────────────────────────────────────
  # Serial console for VM access (matching OPNsense serialspeed 115200)
  boot.kernelParams = ["console=ttyS0,115200n8" "console=tty1"];

  # Bash aliases for convenience
  programs.bash.interactiveShellInit = ''
    alias fetch_pull_rebuild="git fetch --all && git reset --hard origin/main && nixos-rebuild switch --flake"
    alias fw-status="nft list ruleset"
    alias fw-connections="conntrack -L"
    alias dhcp-leases="cat /var/lib/dnsmasq/dnsmasq.leases"
  '';
}
