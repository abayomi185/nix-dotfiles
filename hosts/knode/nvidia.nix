# knode6: RTX 3090 by PCIe passthrough, headless.
#
# The container toolkit writes a CDI spec to
# /var/run/cdi/nvidia-container-toolkit.json. k3s' containerd (2.x) reads CDI
# specs by default, so a CDI device plugin in home-ops can hand the GPU to pods.
# See nixpkgs pkgs/applications/networking/cluster/k3s/docs/examples/NVIDIA.md.
{
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
}
