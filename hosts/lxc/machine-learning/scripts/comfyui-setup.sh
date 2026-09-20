#!/usr/bin/env bash
set -euo pipefail

# Run explicitly as ml, outside activation. Downloads stay out of the Nix store.
comfy_dir="$HOME/ComfyUI"
comfy_rev=c194dd00cd42aa18d9dbf27d977bf6b85d9ea565
if [ ! -d "$comfy_dir" ]; then
  git clone https://github.com/Comfy-Org/ComfyUI.git "$comfy_dir"
fi
git -C "$comfy_dir" diff --exit-code
git -C "$comfy_dir" diff --cached --exit-code
git -C "$comfy_dir" fetch origin "$comfy_rev"
git -C "$comfy_dir" checkout --detach "$comfy_rev"
if [ ! -x "$comfy_dir/.venv/bin/python" ]; then
  uv venv --python 3.12 "$comfy_dir/.venv"
fi
uv pip install --python "$comfy_dir/.venv/bin/python" \
  torch==2.14.0 torchvision==0.29.0 torchaudio==2.11.0 \
  --index-url https://download.pytorch.org/whl/cu130
uv pip install --python "$comfy_dir/.venv/bin/python" -r "$comfy_dir/requirements.txt"

# Standard-library-only extension using ComfyUI's own queue unload flags.
autofree_dir="$comfy_dir/custom_nodes/ComfyUI-AutoFreeMemory"
autofree_rev=a00d3a6827128c33c81556ba10972b2348f3ab2c
if [ ! -d "$autofree_dir" ]; then
  git clone https://github.com/Nlepetit/ComfyUI-AutoFreeMemory.git "$autofree_dir"
fi
git -C "$autofree_dir" diff --exit-code
git -C "$autofree_dir" diff --cached --exit-code
git -C "$autofree_dir" fetch origin "$autofree_rev"
git -C "$autofree_dir" checkout --detach "$autofree_rev"
# Seed the UI defaults too: its 30-second default would override the environment.
"$comfy_dir/.venv/bin/python" - "$comfy_dir" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1]) / "user/default/comfy.settings.json"
path.parent.mkdir(parents=True, exist_ok=True)
settings = json.loads(path.read_text()) if path.exists() else {}
for key, value in {
    "AutoFreeMemory.enabled": True,
    "AutoFreeMemory.idle_seconds": 300,
    "AutoFreeMemory.poll_interval": 3,
}.items():
    settings.setdefault(key, value)
temporary = path.with_suffix(".json.tmp")
temporary.write_text(json.dumps(settings, indent=2) + "\n")
temporary.replace(path)
PY

for model_path in \
  diffusion_models/qwen_image_2.1_int8_convrot.safetensors \
  text_encoders/qwen3vl_8b_int8_convrot.safetensors \
  vae/qwen_image_2.1_vae_bf16.safetensors; do
  destination="$comfy_dir/models/$model_path"
  mkdir -p "$(dirname "$destination")"
  if [ ! -f "$destination" ]; then
    curl --fail --location --retry 5 --continue-at - \
      --output "$destination.part" \
      "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/$model_path"
    mv "$destination.part" "$destination"
  fi
done

(
  cd "$comfy_dir/models"
  sha256sum --check <<'SHA256'
cb74113cb03faecd79611b01fd7fd642f0aa60d6f0b95086abee214d75eaa57d  diffusion_models/qwen_image_2.1_int8_convrot.safetensors
8bfd0f6e12abf2d2d697ecc888e5e90b0d6741d6708f05799f53afa560452e8f  text_encoders/qwen3vl_8b_int8_convrot.safetensors
bb21f7473051e1ac368515dd3f2e15cd44d7a11748ee8823e1ddca3e4876b7c9  vae/qwen_image_2.1_vae_bf16.safetensors
SHA256
)

workflow_rev=371a7b7171bbd11e9cc92ef615ba5ad223d7e5b4
if [ ! -f "$comfy_dir/input/qwen-example-portrait.png" ]; then
  mkdir -p "$comfy_dir/input"
  curl --fail --location --retry 5 --output "$comfy_dir/input/qwen-example-portrait.png.part" \
    "https://raw.githubusercontent.com/Comfy-Org/workflow_templates/$workflow_rev/input/portrait_model_denim.png"
  mv "$comfy_dir/input/qwen-example-portrait.png.part" "$comfy_dir/input/qwen-example-portrait.png"
fi
mkdir -p "$comfy_dir/user/default/workflows"
for workflow in t2i image_edit; do
  destination="$comfy_dir/user/default/workflows/Qwen-Image-2.1-$workflow.json"
  if [ ! -f "$destination" ]; then
    curl --fail --location --retry 5 --output "$destination.part" \
      "https://raw.githubusercontent.com/Comfy-Org/workflow_templates/$workflow_rev/templates/image_qwen_image_2_1_$workflow.json"
    mv "$destination.part" "$destination"
  fi
done
