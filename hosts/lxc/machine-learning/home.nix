{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  # llama-cpp (bleeding edge flake, HTTPS-enabled, wrapped for host NVIDIA driver libs on Ubuntu)
  llamaCppWrapped = let
    llamaCpp = inputs.llama-cpp.packages.${pkgs.stdenv.hostPlatform.system}.cuda.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [pkgs.openssl];
      cmakeFlags =
        (old.cmakeFlags or [])
        ++ [
          "-DLLAMA_OPENSSL=ON"
          "-DLLAMA_BUILD_EXAMPLES=OFF"
          "-DLLAMA_BUILD_TESTS=OFF"
        ];
    });
  in
    pkgs.runCommand "llama-cpp" {nativeBuildInputs = [pkgs.makeWrapper];} ''
      mkdir -p $out/bin $out/nvidia-driver

      ln -s /usr/lib/x86_64-linux-gnu/libcuda.so $out/nvidia-driver/libcuda.so
      ln -s /usr/lib/x86_64-linux-gnu/libcuda.so.1 $out/nvidia-driver/libcuda.so.1
      ln -s /usr/lib/x86_64-linux-gnu/libnvidia-ml.so $out/nvidia-driver/libnvidia-ml.so
      ln -s /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 $out/nvidia-driver/libnvidia-ml.so.1

      for bin in ${llamaCpp}/bin/*; do
        makeWrapper "$bin" "$out/bin/$(basename $bin)" \
          --prefix LD_LIBRARY_PATH : $out/nvidia-driver
      done
    '';
in {
  imports = [
    outputs.homeManagerModules.services.llama-server
    outputs.homeManagerModules.terminal.zellij
    outputs.homeManagerModules.shell.zoxide
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home.username = "ml";
  home.homeDirectory = "/home/ml";
  home.packages = with pkgs; [
    age
    alejandra
    bun
    nil
    nixpkgs-fmt
    btop
    lazygit
    lua-language-server
    nodejs_22
    stylua
    selene
    ssh-to-age
    uv

    llamaCppWrapped
  ];

  # llama-server in router mode for multi-model serving
  services.llama-server = {
    enable = true;
    package = llamaCppWrapped;
    host = "0.0.0.0";
    port = 9000;
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
    # zshrc equivalent
    # initExtra = "";
    # zshenv equivalent
    # envExtra = "";
    # zprofile equivalent
    # profileExtra = "";

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "fzf" "vi-mode"];
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

    settings = {
      user = {
        name = "yomi+git_homelab_lxc_ml_ml@yomitosh.com";
        email = "Yomi Ikuru";
      };
    };
  };

  programs.starship = {
    enable = true;

    settings = {
      nix_shell = {
        disabled = false;
        impure_msg = "";
        symbol = "";
        format = "[$symbol$state]($style) ";
      };
      shlvl = {
        disabled = false;
        symbol = "λ ";
      };
    };
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "25.05";
}
