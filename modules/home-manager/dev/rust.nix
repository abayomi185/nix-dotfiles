{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  home.packages = with pkgs; [
    rust-bin.stable.latest.default
    # rust-bin.stable.latest.default.override
    # {
    #   extensions = ["rust-src" "rust-analyzer"];
    #   targets = ["arm-unknown-linux-gnueabihf"];
    # }
  ];
}
