{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.llama-server;
in {
  home.packages = with pkgs.unstable; [
    llama-cpp
  ];

  # ── llama-server service (may be removed) ──────────────────────

  options.services.llama-server = {
    enable = lib.mkEnableOption "llama-server";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The llama-cpp package to use for llama-server.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Host address to bind to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the llama-server to listen on.";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional flags to pass to llama-server.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.llama-server = {
      Unit = {
        Description = "llama.cpp server";
        After = ["network-online.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = let
          flags =
            [
              "--host"
              cfg.host
              "--port"
              (toString cfg.port)
            ]
            ++ cfg.extraFlags;
        in "${cfg.package}/bin/llama-server ${lib.concatStringsSep " " flags}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
