# knode6: RTX 3090 by PCIe passthrough, headless.
#
# The container toolkit writes a CDI spec to
# /var/run/cdi/nvidia-container-toolkit.json. k3s finds
# nvidia-container-runtime.cdi on its PATH and registers the `nvidia-cdi`
# containerd runtime, which injects that spec. Pods opt in with the home-ops
# `gpu` RuntimeClass; no device plugin, so any number of pods share the card.
{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  # Selects the NVIDIA driver; no X server runs.
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    nvidiaSettings = false;
    # Keeps the driver initialised without a client, as on a headless server.
    nvidiaPersistenced = true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  systemd.services.k3s.path = [pkgs.nvidia-container-toolkit.tools];
}
