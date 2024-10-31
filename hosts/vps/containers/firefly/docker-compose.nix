# Auto-generated using compose2nix v0.2.1-pre.
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Secrets
  age.secrets.vps_containers_firefly_iii.file = "${inputs.nix-secrets}/hosts/vps/containers/firefly-iii/env.age";
  age.secrets.vps_containers_firefly_iii_db.file = "${inputs.nix-secrets}/hosts/vps/containers/firefly-iii/db.env.age";
  age.secrets.vps_containers_firefly_iii_cron.file = "${inputs.nix-secrets}/hosts/vps/containers/firefly-iii/cron.env.age";
  age.secrets.vps_containers_firefly_iii_data_importer.file = "${inputs.nix-secrets}/hosts/vps/containers/firefly-iii/fidi.env.age";

  networking.firewall.interfaces.podman0.allowedUDPPorts = [53];

  # Containers

  ### Firefly App
  virtualisation.oci-containers.containers."firefly-app" = {
    image = "fireflyiii/core:latest";
    environmentFiles = [
      config.age.secrets.vps_containers_firefly_iii.path
    ];
    volumes = [
      "firefly_firefly_iii_upload:/var/www/html/storage/upload:rw"
    ];
    ports = [
      "127.0.0.1:8077:8080/tcp"
    ];
    dependsOn = [
      "firefly-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--hostname=firefly-app"
      "--network-alias=app"
      "--network=firefly_default"
    ];
  };
  systemd.services."podman-firefly-app" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      User = "cloud";
    };
    after = [
      "podman-network-firefly_default.service"
      "podman-volume-firefly_firefly_iii_upload.service"
    ];
    requires = [
      "podman-network-firefly_default.service"
      "podman-volume-firefly_firefly_iii_upload.service"
    ];
    partOf = [
      "podman-compose-firefly-root.target"
    ];
    wantedBy = [
      "podman-compose-firefly-root.target"
    ];
  };

  ### Firefly DB
  virtualisation.oci-containers.containers."firefly-db" = {
    image = "mariadb:lts";
    environmentFiles = [
      config.age.secrets.vps_containers_firefly_iii_db.path
    ];
    volumes = [
      "firefly_firefly_iii_db:/var/lib/mysql:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--hostname=firefly-db"
      "--network-alias=db"
      "--network=firefly_default"
    ];
  };
  systemd.services."podman-firefly-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      User = "cloud";
    };
    after = [
      "podman-network-firefly_default.service"
      "podman-volume-firefly_firefly_iii_db.service"
    ];
    requires = [
      "podman-network-firefly_default.service"
      "podman-volume-firefly_firefly_iii_db.service"
    ];
    partOf = [
      "podman-compose-firefly-root.target"
    ];
    wantedBy = [
      "podman-compose-firefly-root.target"
    ];
  };

  ### Firefly FIDI
  virtualisation.oci-containers.containers."firefly-fidi" = {
    image = "fireflyiii/data-importer:latest";
    environmentFiles = [
      config.age.secrets.vps_containers_firefly_iii_data_importer.path
    ];
    ports = [
      "127.0.0.1:8078:8080/tcp"
    ];
    dependsOn = [
      "firefly-app"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=fidi"
      "--network=firefly_default"
    ];
  };
  systemd.services."podman-firefly-fidi" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      User = "cloud";
    };
    after = [
      "podman-network-firefly_default.service"
    ];
    requires = [
      "podman-network-firefly_default.service"
    ];
    partOf = [
      "podman-compose-firefly-root.target"
    ];
    wantedBy = [
      "podman-compose-firefly-root.target"
    ];
  };

  ### Firefly Cron
  virtualisation.oci-containers.containers."firefly_iii_cron" = {
    image = "alpine";
    environmentFiles = [
      config.age.secrets.vps_containers_firefly_iii_cron.path
    ];
    cmd = ["sh" "-c" "echo \"0 3 * * * wget -qO- \" | crontab - && crond -f -L /dev/stdout"];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cron"
      "--network=firefly_firefly_iii"
    ];
  };
  systemd.services."podman-firefly_iii_cron" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      User = "cloud";
    };
    after = [
      "podman-network-firefly_firefly_iii.service"
    ];
    requires = [
      "podman-network-firefly_firefly_iii.service"
    ];
    partOf = [
      "podman-compose-firefly-root.target"
    ];
    wantedBy = [
      "podman-compose-firefly-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-firefly_default" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f firefly_default";
      User = "cloud";
    };
    script = ''
      podman network inspect firefly_default || podman network create firefly_default
    '';
    partOf = ["podman-compose-firefly-root.target"];
    wantedBy = ["podman-compose-firefly-root.target"];
  };
  systemd.services."podman-network-firefly_firefly_iii" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f firefly_firefly_iii";
      User = "cloud";
    };
    script = ''
      podman network inspect firefly_firefly_iii || podman network create firefly_firefly_iii --driver=bridge
    '';
    partOf = ["podman-compose-firefly-root.target"];
    wantedBy = ["podman-compose-firefly-root.target"];
  };

  # Volumes
  systemd.services."podman-volume-firefly_firefly_iii_db" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "cloud";
    };
    script = ''
      podman volume inspect firefly_firefly_iii_db || podman volume create firefly_firefly_iii_db
    '';
    partOf = ["podman-compose-firefly-root.target"];
    wantedBy = ["podman-compose-firefly-root.target"];
  };
  systemd.services."podman-volume-firefly_firefly_iii_upload" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "cloud";
    };
    script = ''
      podman volume inspect firefly_firefly_iii_upload || podman volume create firefly_firefly_iii_upload
    '';
    partOf = ["podman-compose-firefly-root.target"];
    wantedBy = ["podman-compose-firefly-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-firefly-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
