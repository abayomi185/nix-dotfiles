{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys =
    [
      "# CHANGE_ME"
    ]
    ++ (args.extraPublicKeys or []);

  system.stateVersion = "25.11";
}
