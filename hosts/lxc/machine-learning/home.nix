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
    outputs.homeManagerModules.shell.fzf
    outputs.homeManagerModules.shell.zoxide
    outputs.homeManagerModules.terminal.zellij
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

  # llama-server for the tuned Qwen3.6 single-model setup
  services.llama-server = {
    enable = true;
    package = llamaCppWrapped;
    host = "0.0.0.0";
    port = 9000;
    extraFlags = [
      "-hf"
      "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL"
      "--fit"
      "on"
      "--fit-ctx"
      "131072"
      "--fit-target"
      "512"
      "-np"
      "1"
      "-t"
      "32"
      "-tb"
      "32"
      "-fa"
      "on"
      "-ctk"
      "q8_0"
      "-ctv"
      "q8_0"
      "-b"
      "2048"
      "-ub"
      "2048"
      "--mlock"
      "--metrics"
      "--no-webui"
      "--no-mmproj"
    ];
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
