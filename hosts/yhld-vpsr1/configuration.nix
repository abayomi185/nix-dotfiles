# YHLD-VPSR1 — Euronodes x86 VPS.
{
  lib,
  inputs,
  modulesPath,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  vpnHubSecrets = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");

  cloudflareIpv4Cidrs = [
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
  ];

  cloudflareIpv6Cidrs = [
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];

  mkCloudflareAcceptRules = action: let
    suffix = lib.optionalString (action == "-D") " || true";
  in
    lib.concatStringsSep "\n" (
      (map (cidr: "${pkgs.iptables}/bin/iptables ${action} nixos-fw -p tcp -m multiport --dports 80,443 -s ${cidr} -j nixos-fw-accept${suffix}") cloudflareIpv4Cidrs)
      ++ (map (cidr: "${pkgs.iptables}/bin/ip6tables ${action} nixos-fw -p tcp -m multiport --dports 80,443 -s ${cidr} -j nixos-fw-accept${suffix}") cloudflareIpv6Cidrs)
    );
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./wireguard.nix
    ./k3s.nix
  ];

  # ── Boot ───────────────────────────────────────────────────────────────
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.kernelParams = ["console=ttyS0,115200n8" "console=tty1"];

  # ── System ─────────────────────────────────────────────────────────────
  networking.hostName = "yhld-vpsr1";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  system.stateVersion = "26.05";

  # ── Nix ────────────────────────────────────────────────────────────────
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

  # ── Secrets ────────────────────────────────────────────────────────────
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${inputs.nix-secrets}/hosts/yhld-vpsr1/default.enc.yaml";
  };

  zramSwap.enable = true;

  # ── Networking ─────────────────────────────────────────────────────────
  networking.useDHCP = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      8888 # tinyproxy
    ];
    # Keep the Cloudflare-proxied origin private: only Cloudflare can reach
    # public HTTP(S) on the VPS. SSH/tinyproxy and WireGuard/k3s ports remain
    # managed by the normal NixOS firewall allow lists.
    extraCommands = mkCloudflareAcceptRules "-A";
    extraStopCommands = mkCloudflareAcceptRules "-D";
  };

  programs.zsh.enable = true;

  # ── Access ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = import ../shared/authorized-keys.nix {inherit inputs;};
  users.users.cloud = {
    isNormalUser = true;
    description = "cloud";
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = import ../shared/authorized-keys.nix {inherit inputs;};
  };
  security.sudo.wheelNeedsPassword = false;

  # ── Services ───────────────────────────────────────────────────────────
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
  };
  services.tinyproxy = {
    enable = true;
    settings = {
      Listen = "0.0.0.0";
      Port = 8888;
      BasicAuth = "tinyproxy ${vpnHubSecrets.user.initial_password}";
    };
  };

  # ── Packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    btop
    curl
    dnsutils
    gitMinimal
    htop
    neovim
    tcpdump
    traceroute
  ];
}
