{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  networking.hostName = "livecd";

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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  users.users.nixos.initialHashedPassword = lib.mkForce "";

  system.stateVersion = "25.11";
}
