# Make sure that the brave package in nixpkgs has an override method
# which supports the commandLineArgs attribute.
# If it doesn't, you will need to find a different approach to customize the package,
# such as using wrapProgram in a pkgs.stdenv.mkDerivation
{pkgs, ...}: {
  # nixpkgs.overlays = [
  #   (self: super: {
  #     brave = super.brave.override {
  #       commandLineArgs = "--enable-features=TouchpadOverscrollHistoryNavigation";
  #     };
  #   })
  # ];
  #
  # home.packages = with pkgs; [brave];

  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      # "--password-store=gnome-libsecret"
    ];
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
      {id = "hfjbmagddngcpeloejdejnfgbamkjaeg";} # Vimium C
      {id = "nffaoalbilbmmfgbnbgppjihopabppdk";} # Video speed controller
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto Tab Discard
      {id = "niloccemoadcdkdjlinkgdfekeahmflj";} # Pocket
    ];
  };
}
