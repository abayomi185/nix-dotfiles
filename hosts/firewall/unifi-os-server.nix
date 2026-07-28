# UniFi OS Server — containerized network controller
{...}: {
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };

  services.unifi-os-server = {
    enable = true;
    # Stable address reachable by devices on every routed LAN.
    uosSystemIP = "10.1.10.1";
  };
}
