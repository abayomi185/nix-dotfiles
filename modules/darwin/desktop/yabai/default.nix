{pkgs, ...}: let
  # Fixed-path copy so the Accessibility grant survives brew upgrades; see
  # ../skhd/default.nix. yabai is signed with a stable cert, so the grant
  # carries across versions.
  bin = "/usr/local/libexec/yabai";
in {
  # Installed with Homebrew rather than Nix; see ../skhd/default.nix for why.
  homebrew.taps = [
    {
      name = "asmvik/formulae"; # koekeishiya/formulae was renamed
      trusted = true;
    }
  ];
  homebrew.brews = ["asmvik/formulae/yabai"];

  system.activationScripts.postActivation.text = ''
    if ! cmp -s /opt/homebrew/bin/yabai ${bin}; then
      mkdir -p /usr/local/libexec
      cp /opt/homebrew/bin/yabai ${bin}.new
      mv -f ${bin}.new ${bin}
      pkill -x yabai || true
    fi
  '';

  services.yabai = {
    enable = true;
    package = pkgs.runCommand "yabai-brew" {} ''
      mkdir -p $out/bin
      ln -s ${bin} $out/bin/yabai
    '';
    config = {
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = 0.00;
      active_window_opacity = 1.0;
      auto_balance = "off";
      split_ratio = 0.50;
      mouse_modifier = "ctrl";
      mouse_action2 = "resize";
      mouse_action1 = "move";
      layout = "bsp";
      top_padding = 2;
      bottom_padding = 2;
      left_padding = 2;
      right_padding = 2;
      window_gap = 12;
    };

    extraConfig = builtins.readFile ./yabairc;
  };
}
