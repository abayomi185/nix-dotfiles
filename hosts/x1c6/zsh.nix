# See common config here: ../../modules/home-manager/shell/zsh.nix
{
  # Common configuration for Zsh
  programs.zsh = {
    # zshenv equivalent
    envExtra = ''
      export lang=en_us.utf-8
      # export path=$home/bin:$path
      # other environment variables or initialization commands
    '';

    # zplug = {
    #   plugins = [
    #   ];
    # };
  };

  programs.direnv.enable = true;
}
