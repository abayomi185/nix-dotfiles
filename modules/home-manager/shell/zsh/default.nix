{hostConfig, ...}: {
  imports = [import ./common.nix {inherit hostConfig;}];
}
