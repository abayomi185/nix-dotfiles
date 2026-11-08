{
  inputs,
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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = [pkgs.neovim];

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
}
