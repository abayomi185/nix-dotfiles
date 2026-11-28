# YHLD-VPSR1 — Euronodes x86 VPS.
{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
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

  # BBR keeps throughput up on lossy, high-RTT client links (e.g. remote VPN streaming)
  boot.kernelModules = ["tcp_bbr"];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80 # public HTTP for in-cluster Traefik
      443 # public HTTPS for in-cluster Traefik
    ];
    # VPN-only services
    interfaces.wg0.allowedTCPPorts = [
      8191 # flaresolverr
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

  # Bans brute-forcing IPs on the public SSH port (sshd jail is on by default).
  services.fail2ban = {
    enable = true;
    ignoreIP = ["10.13.13.0/24"];
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
  services.flaresolverr.enable = true;

  # The module renders settings into the Nix store, so the config (with the
  # BasicAuth password) comes from a sops template instead.
  services.tinyproxy.enable = true;
  sops.secrets."tinyproxy/basicAuthPassword" = {};
  sops.templates."tinyproxy.conf" = {
    owner = "tinyproxy";
    restartUnits = ["tinyproxy.service"];
    content = ''
      Listen 0.0.0.0
      Port 8888
      BasicAuth tinyproxy ${config.sops.placeholder."tinyproxy/basicAuthPassword"}
    '';
  };
  systemd.services.tinyproxy.serviceConfig.ExecStart =
    lib.mkForce "${lib.getExe config.services.tinyproxy.package} -d -c ${config.sops.templates."tinyproxy.conf".path}";

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
