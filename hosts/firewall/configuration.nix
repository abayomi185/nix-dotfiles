# NixOS router VM — main configuration (migrated from OPNsense).
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./networking.nix
    ./nftables.nix
    ./dns.nix
    ./dhcp.nix
    ./wireguard.nix
    ./services.nix
  ];

  # ── Nix ──────────────────────────────────────────────────────────────────
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

  # ── Boot ───────────────────────────────────────────────────────────────
  # UEFI grub, matching the other Proxmox VMs (knodes). The VM must use OVMF.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  # Serial console for `qm terminal` / Proxmox console access.
  boot.kernelParams = ["console=ttyS0,115200n8" "console=tty1"];

  # ── System ─────────────────────────────────────────────────────────────
  system.stateVersion = "25.11";
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Secrets (sops, decrypted with the host SSH key) ────────────────────
  sops = {
    age.sshKeyPaths = ["/root/.ssh/id_ed25519"];
    defaultSopsFile = "${inputs.nix-secrets}/hosts/firewall/default.enc.yaml";
  };

  # ── Packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    neovim
    htop
    tcpdump
    nftables
    ethtool
    conntrack-tools
    wireguard-tools
    dnsutils
    traceroute
    iperf3
  ];

  # ── Users ──────────────────────────────────────────────────────────────
  users.users.yom = {
    isNormalUser = true;
    description = "Yomi";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys =
      ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUFAxoqI9FZ1z4X+CVoyqwzdeYj/7uqI19U/hNiVQ41"]
      ++ import ../shared/authorized-keys.nix {inherit inputs;};
  };
  users.users.root.openssh.authorizedKeys.keys = import ../shared/authorized-keys.nix {inherit inputs;};

  # Admin convenience; SSH access is already key-only (see services.nix).
  security.sudo.wheelNeedsPassword = false;

  programs.bash.interactiveShellInit = ''
    alias fw-status="nft list ruleset"
    alias fw-connections="conntrack -L"
    alias dhcp-leases="cat /var/lib/dnsmasq/dnsmasq.leases"
  '';
}
