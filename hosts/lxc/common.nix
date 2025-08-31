{...}: {
  programs.bash.interactiveShellInit = ''
    alias fetch_pull_rebuild="git fetch --all && git reset --hard origin/main && nixos-rebuild switch --flake .#load-balancer"
  '';
}
