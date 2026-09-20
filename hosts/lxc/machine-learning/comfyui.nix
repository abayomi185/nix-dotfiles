{
  lib,
  pkgs,
  ...
}: let
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

  # Seed editable workflows without replacing changes saved through the UI.
  home.activation.comfyuiWorkflows = lib.hm.dag.entryAfter ["writeBoundary"] ''
    workflowDir="$HOME/ComfyUI/user/default/workflows"
    run mkdir -p "$workflowDir"
    for workflow in ${./workflows}/*.json; do
      destination="$workflowDir/$(basename "$workflow")"
      if [ ! -e "$destination" ]; then
        run cp "$workflow" "$destination"
        run chmod u+w "$destination"
      fi
    done
  '';

  # The initial live deployment preserves the installed llama.cpp binary.
  # Remove its temporary override once home.nix supplies the native idle flag.
  home.activation.removeLlamaIdleBootstrap = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run rm -f "$HOME/.config/systemd/user/llama-server.service.d/90-idle-bootstrap.conf"
  '';

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
      Environment = [
        "PYTHONUNBUFFERED=1"
        "COMFYUI_AUTOFREE_ENABLED=1"
        "COMFYUI_AUTOFREE_IDLE_SECONDS=300"
        "COMFYUI_AUTOFREE_POLL_INTERVAL=3"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 30;
      UMask = "0027";
    };
    Install.WantedBy = ["default.target"];
  };
}
