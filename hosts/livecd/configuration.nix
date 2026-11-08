{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal-combined.nix"
    # Harmless on bare metal; lets Proxmox see the VM address.
    "${inputs.nixpkgs-stable}/nixos/modules/profiles/qemu-guest.nix"
  ];

  networking.hostName = "livecd";
  boot.zfs.forceImportRoot = false;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
  ];

  services.qemuGuest.enable = true;

  # Key-only root SSH, so nixos-anywhere needs no console step.
  # NOTE: For password login, set PermitRootLogin = "yes" and
  # PasswordAuthentication = true, then run `passwd` at the console.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys =
    import ../shared/authorized-keys.nix {inherit inputs;};

  users.users.nixos.initialHashedPassword = lib.mkForce "";

  system.stateVersion = "25.11";
}
