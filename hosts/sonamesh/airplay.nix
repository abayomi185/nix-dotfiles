{
  config,
  pkgs,
  ...
}: let
  # AES67 already owns PTP ports 319/320. Classic AirPlay needs no NQPTP.
  package = pkgs.shairport-sync.override {enableAirplay2 = false;};
  sinkName = "sonamesh.airplay";
  configFile = (pkgs.formats.libconfig {}).generate "sonamesh-airplay.conf" {
    general = {
      name = "SonaMesh Speakers";
      output_backend = "pipewire";
      mdns_backend = "avahi";
      port = 5000;
      udp_port_base = 6001;
      udp_port_range = 10;
    };
    pipewire = {
      application_name = "SonaMesh AirPlay";
      node_name = "sonamesh.airplay.receiver";
      sink_target = sinkName;
    };
    diagnostics.log_output_to = "stderr";
  };
in {
  services.avahi.publish.userServices = true;
  networking.firewall = {
    allowedTCPPorts = [5000];
    allowedUDPPortRanges = [
      {
        from = 6001;
        to = 6010;
      }
    ];
  };

  # Map stereo to the same physical pair as the SonaMesh playback routes.
  services.pipewire.extraConfig.pipewire."20-airplay" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "SonaMesh AirPlay stereo";
          "capture.props" = {
            "node.name" = sinkName;
            "media.class" = "Audio/Sink";
            "audio.position" = ["FL" "FR"];
            "priority.session" = 1;
          };
          "playback.props" = {
            "node.name" = "sonamesh.airplay.output";
            "audio.position" = ["AUX0" "AUX1"];
            "target.object" = config.services.sonamesh.pipewire.outputNode;
            "stream.dont-remix" = true;
            "node.passive" = true;
          };
        };
      }
    ];
  };

  systemd.user.services.shairport-sync = {
    description = "SonaMesh AirPlay receiver";
    wantedBy = ["default.target"];
    partOf = ["pipewire.service"];
    wants = ["pipewire.service" "wireplumber.service"];
    after = ["pipewire.service" "wireplumber.service"];
    unitConfig.ConditionUser = "sonamesh";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${package}/bin/shairport-sync -c ${configFile}";
      Restart = "always";
      RestartSec = "3s";
    };
  };
  environment.systemPackages = [package];
}
