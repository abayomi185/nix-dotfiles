{pkgs, ...}: {
  imports = [];

  home.username = "cloud";
  home.homeDirectory = "/home/cloud";
  home.packages = with pkgs; [
    age
    alejandra
    nil
    nixpkgs-fmt
    btop
    lazygit
    ssh-to-age
  ];

  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    settings = {
      user = {
        name = "Yomi Ikuru";
        email = "yomi+git_cloud_yhld-vpsr1@yomitosh.com";
      };
    };
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      la = "ls -la";
      check = "nix flake check";
      update = "sudo nixos-rebuild switch";
      garbage = "sudo nix-collect-garbage --delete-older-than";
      develop = "nix develop -c $SHELL";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "vi-mode"];
      theme = "robbyrussell";
    };
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "26.05";
}
