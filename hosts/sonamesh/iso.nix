{
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.zfs.forceImportRoot = false;

  networking.hostName = "sonamesh-installer";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root"];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    qemuGuest.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys =
    import ../shared/authorized-keys.nix {inherit inputs;};

  system.stateVersion = "26.05";
}
