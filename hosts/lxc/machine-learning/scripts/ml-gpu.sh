#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  comfyui)
    systemctl --user stop llama-server
    systemctl --user start comfyui
    ;;
  llama)
    # Stopping the process releases both VRAM and host RAM immediately.
    systemctl --user stop comfyui
    systemctl --user start llama-server
    ;;
  *)
    echo 'Usage: ml-gpu comfyui|llama' >&2
    exit 2
    ;;
esac
