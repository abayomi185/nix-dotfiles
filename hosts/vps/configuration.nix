{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsJson = builtins.fromTOML (builtins.readFile "${secretsPath}/hosts/vps/secrets.toml");

  secret_initialPassword = secretsJson.user.initial_password;
  secret_authorizedKeys = secretsJson.ssh.authorized_keys;

  homeDir = "/home/cloud";
in {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./wireguard.nix

    # Containers
    # ./containers/traefik/docker-compose.nix # Traefik
    # ./containers/firefly/docker-compose.nix # Firefly

    # Services
    ./apps/authelia
    ./apps/firefly-iii
    ./apps/traefik
    ./apps/uptime-kuma
  ];

  # Secrets
  sops = {
    age.sshKeyPaths = ["/home/cloud/.ssh/id_ed25519"];
    defaultSopsFile = "${inputs.nix-secrets}/hosts/vps/default.enc.yaml";
  };
  age.identityPaths = ["${homeDir}/.ssh/id_ed25519"];

  # Hetzner
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vps-arm64";
  networking.domain = "";

  programs.nix-ld.enable = true; # Enable nix-ld - it just works

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

  # Shell
  programs.zsh = {enable = true;};
  # Define a user account
  users.users = {
    cloud = {
      isNormalUser = true;
      description = "cloud";
      shell = pkgs.zsh;
      extraGroups = ["wheel" "docker" "oci" "podman"];
      initialPassword = secret_initialPassword;
    };
  };

  # Containers
  # virtualisation.docker.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

  # Programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Services
  services.openssh = {
    enable = true;
    # Let's not repeat last time's mistake
    # settings = {
    #   PermitRootLogin = "no";
    # };
  };
  users.users.root.openssh.authorizedKeys.keys = [];
  users.users.cloud.openssh.authorizedKeys.keys = secret_authorizedKeys;

  # Fail2ban
  # services.fail2ban.enable = true;
  # NixOS by default is pre-configured with SSH jail

  # System Packages
  environment.systemPackages = with pkgs; [
    zig
    podman-tui
    podman-compose
    inputs.compose2nix.packages.${system}.default
    inputs.agenix.packages.${system}.default
  ];

  system.stateVersion = "23.11";
}
