# UniFi OS Server — containerized network controller
{pkgs, ...}: let
  networkVersion = "10.5.67";
  networkPackage = pkgs.fetchurl {
    url = "https://dl.ui.com/unifi/${networkVersion}/unifi-uos_sysvinit.deb";
    hash = "sha256-BS2eoApq+q8iXBydibPI1PZBQ+RooxklWoCUQPWXIhE=";
  };
in {
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };

  services.unifi-os-server = {
    enable = true;
    # Stable address reachable by devices on every routed LAN.
    uosSystemIP = "10.1.10.1";
    extraVolumes = ["${networkPackage}:/run/unifi-network.deb:ro"];
  };

  # OS Server 5.1.21 bundles Network 10.4.57, while its application updater
  # produces 10.5.67 databases. Upgrade fresh containers before using their
  # persistent database, but never downgrade a newer container overlay.
  systemd.services.podman-unifi-os-server.postStart = ''
    installed="$(${pkgs.podman}/bin/podman exec unifi-os-server \
      dpkg-query --show unifi | ${pkgs.coreutils}/bin/cut --fields=2)"
    if ${pkgs.dpkg}/bin/dpkg --compare-versions "$installed" lt "${networkVersion}"; then
      ${pkgs.podman}/bin/podman exec unifi-os-server \
        dpkg --install /run/unifi-network.deb
      ${pkgs.podman}/bin/podman exec unifi-os-server \
        systemctl restart unifi.service
    fi
  '';
}
