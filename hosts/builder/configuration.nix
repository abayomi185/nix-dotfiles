{
  inputs,
  modulesPath,
  pkgs,
  ...
}: {
  imports = ["${modulesPath}/profiles/qemu-guest.nix"];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.qemuGuest.enable = true;

  # Emulated aarch64-linux builds (Raspberry Pi images). Unlike the
  # machine-learning LXC, a VM registers binfmt itself.
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  networking = {
    hostName = "builder";
    domain = "internal.yomitosh.media";
    useDHCP = true;
  };
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Remote builds connect as root, which Nix trusts by default.
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "prohibit-password";
  };
  users.users.root.openssh.authorizedKeys.keys = import ../shared/authorized-keys.nix {inherit inputs;};

  environment.systemPackages = with pkgs; [git];
  system.stateVersion = "26.05";
}
