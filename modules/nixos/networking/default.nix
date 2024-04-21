{
  bluetooth = import ./bluetooth.nix;

  iwd = import ./iwd.nix;

  network-manager = import ./network-manager.nix;

  tailscale = import ./tailscale.nix;

  # wireguard = import ./wireguard;
}
