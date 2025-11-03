{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    llama-swap
  ];
}
