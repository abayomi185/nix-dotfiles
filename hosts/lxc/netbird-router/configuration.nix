# NetBird routing peer: gives NetBird clients the home LANs (networks and
# policies in infra/netbird). Kept off the firewall so the trial can't disturb
# the core router; traffic is masqueraded, so the LANs need no return routes.
{
  config,
  inputs,
  modulesPath,
  pkgs,
  ...
}: let
  defaultLocale = "en_GB.UTF-8";
in {
  imports = ["${modulesPath}/virtualisation/lxc-container.nix"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.isContainer = true;
  networking.hostName = "netbird-router";
  networking.useDHCP = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = defaultLocale;

  # Supress systemd units that don't work because of LXC.
  # https://blog.xirion.net/posts/nixos-proxmox-lxc/#configurationnix-tweak
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${inputs.nix-secrets}/hosts/netbird-router/default.enc.yaml";
    secrets."netbird/setupKey" = {};
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = import ../../shared/authorized-keys.nix {inherit inputs;};

  services.netbird = {
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.netbird;
    useRoutingFeatures = "server";
    clients.home = {
      port = 51820;
      environment.NB_MANAGEMENT_URL = "https://netbird.yomitosh.media";
      login = {
        enable = true;
        setupKeyFile = config.sops.secrets."netbird/setupKey".path;
      };
    };
  };

  system.stateVersion = "26.05";
}
