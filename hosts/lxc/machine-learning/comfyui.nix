{pkgs, ...}: let
  gpuSwitch = pkgs.writeShellApplication {
    name = "ml-gpu";
    runtimeInputs = with pkgs; [systemd];
    text = builtins.readFile ./scripts/ml-gpu.sh;
  };
in {
  # Ubuntu supplies the NVIDIA driver; uv supplies the Python/CUDA environment.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "comfyui-setup";
      runtimeInputs = with pkgs; [git uv curl coreutils];
      text = builtins.readFile ./scripts/comfyui-setup.sh;
    })
    gpuSwitch
  ];

  # Also usable by non-interactive SSH sessions before shell profile loading.
  home.file.".local/bin/ml-gpu".source = "${gpuSwitch}/bin/ml-gpu";

  systemd.user.services.comfyui = {
    Unit = {
      Description = "ComfyUI image generation";
      After = ["network-online.target"];
      ConditionPathExists = "%h/ComfyUI/.venv/bin/python";
    };
    Service = {
      Type = "simple";
      WorkingDirectory = "%h/ComfyUI";
      ExecStart = "%h/ComfyUI/.venv/bin/python main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch --disable-api-nodes";
      Environment = ["PYTHONUNBUFFERED=1"];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 30;
      UMask = "0027";
    };
    Install.WantedBy = ["default.target"];
  };
}
