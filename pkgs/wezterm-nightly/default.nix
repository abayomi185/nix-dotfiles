{
  callPackage,
  darwin,
  fontconfig,
  installShellFiles,
  lib,
  libGL,
  libiconv,
  libxkbcommon,
  ncurses,
  nixosTests,
  openssl,
  perl,
  pkgs,
  pkg-config,
  python3,
  runCommand,
  stdenv,
  vulkan-loader,
  wayland,
  xorg,
  zlib,
  # Rust
  makeRustPlatform,
}: let
  inherit (darwin.apple_sdk_11_0.frameworks) CoreGraphics Cocoa Foundation Security UserNotifications System;
  nvfetcher = (callPackage ../_sources/generated.nix {}).wezterm;
  rustPlatform = makeRustPlatform {
    cargo = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
    rustc = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  };
in
  rustPlatform.buildRustPackage rec {
    inherit (nvfetcher) pname src;
    version = "${builtins.replaceStrings ["-"] [""] nvfetcher.date}-abayomi185-${builtins.substring 0 7 nvfetcher.version}";

    cargoLock = nvfetcher.cargoLock."Cargo.lock";
    doCheck = false;

    nativeBuildInputs =
      [
        installShellFiles
        ncurses # tic for terminfo
        pkg-config
        python3
      ]
      ++ lib.optionals stdenv.isDarwin [perl];

    buildInputs =
      [
        fontconfig
        zlib
      ]
      ++ lib.optionals stdenv.isLinux [
        xorg.libX11
        xorg.libxcb
        libxkbcommon
        openssl
        wayland
        xorg.xcbutil
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilwm # contains xcb-ewmh among others
      ]
      ++ lib.optionals stdenv.isDarwin
      [
        Cocoa
        CoreGraphics
        Foundation
        libiconv
        Security
        System
        UserNotifications
      ];

    postPatch = ''
      echo "${version}" > .tag
      # tests are failing with: Unable to exchange encryption keys
      rm -r wezterm-ssh/tests
    '';

    buildFeatures = ["distro-defaults"];
    env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-framework System";

    postInstall = ''
      mkdir -p $out/nix-support
      echo "${passthru.terminfo}" >> $out/nix-support/propagated-user-env-packages

      install -Dm644 assets/icon/terminal.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
      install -Dm644 assets/wezterm.desktop $out/share/applications/org.wezfurlong.wezterm.desktop
      install -Dm644 assets/wezterm.appdata.xml $out/share/metainfo/org.wezfurlong.wezterm.appdata.xml

      install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
      installShellCompletion --cmd wezterm \
        --bash assets/shell-completion/bash \
        --fish assets/shell-completion/fish \
        --zsh assets/shell-completion/zsh

      install -Dm644 assets/wezterm-nautilus.py -t $out/share/nautilus-python/extensions
    '';

    preFixup =
      lib.optionalString stdenv.isLinux ''
        patchelf \
          --add-needed "${libGL}/lib/libEGL.so.1" \
          --add-needed "${vulkan-loader}/lib/libvulkan.so.1" \
          $out/bin/wezterm-gui
      ''
      + lib.optionalString stdenv.isDarwin ''
        mkdir -p "$out/Applications"
        OUT_APP="$out/Applications/WezTerm.app"
        cp -r assets/macos/WezTerm.app "$OUT_APP"
        rm $OUT_APP/*.dylib
        cp -r assets/shell-integration/* "$OUT_APP"
        ln -s $out/bin/{wezterm,wezterm-mux-server,wezterm-gui,strip-ansi-escapes} "$OUT_APP"
      '';

    passthru = {
      tests = {
        all-terminfo = nixosTests.allTerminfo;
        terminal-emulators = nixosTests.terminal-emulators.wezterm;
      };
      terminfo =
        runCommand "wezterm-terminfo"
        {
          nativeBuildInputs = [ncurses];
        } ''
          mkdir -p $out/share/terminfo $out/nix-support
          tic -x -o $out/share/terminfo ${src}/termwiz/data/wezterm.terminfo
        '';
    };

    meta = with lib; {
      description = "GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
      homepage = "https://wezfurlong.org/wezterm";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  }
