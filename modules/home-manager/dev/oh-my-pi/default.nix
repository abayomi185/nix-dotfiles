{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.bun];
  home.sessionPath = lib.mkAfter ["${config.home.homeDirectory}/.bun/bin"];

  home.file."AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/dev/oh-my-pi/AGENTS.md";

  home.file.".bun/bin/omp".source = pkgs.writeShellScript "omp" ''
    exec ${pkgs.bun}/bin/bunx @oh-my-pi/pi-coding-agent@latest "$@"
  '';
}
