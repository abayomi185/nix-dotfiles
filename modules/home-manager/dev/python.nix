{pkgs, ...}: {
  home.packages = with pkgs; [
    python312
    python311
    python310
    virtualenv
  ];
}
