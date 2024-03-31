{ inputs, pkgs, ... }: {
  imports = [
    inputs.rust-overlay.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    rust-bin.stable.latest.default
    # rust-bin.stable.latest.default.override
    # {
    #   extensions = [ "rust-src" ];
    #   targets = [ "arm-unknown-linux-gnueabihf" ];
    # }
  ];

}
