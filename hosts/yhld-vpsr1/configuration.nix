# YHLD-VPSR1 — Euronodes x86 VPS.
{
  inputs,
  modulesPath,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  vpnHubSecrets = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");
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
