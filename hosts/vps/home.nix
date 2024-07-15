{pkgs, ...}: {
  home.username = "cloud";
  home.homeDirectory = "/home/cloud";
  home.packages = with pkgs; [
    alejandra
    nil
    nixpkgs-fmt
    btop
    lazygit
    lua-language-server
    nodejs_18
    stylua
    selene
    ssh-to-age
  ];

  # NOTE: Shells
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
    # zshrc equivalent
    # initExtra = "";
    # zshenv equivalent
    # envExtra = "";
    # zprofile equivalent
    # profileExtra = "";

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "vi-mode"];
      theme = "robbyrussell";
    };
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.bat = {
    enable = true;
  };
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "yomi+git_cloud_vps@yomitosh.com";
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "23.11";
}
