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
mkdir -p "$comfy_dir/user/default/workflows"
for workflow in t2i image_edit; do
  destination="$comfy_dir/user/default/workflows/Qwen-Image-2.1-$workflow.json"
  if [ ! -f "$destination" ]; then
    curl --fail --location --retry 5 --output "$destination.part" \
      "https://raw.githubusercontent.com/Comfy-Org/workflow_templates/$workflow_rev/templates/image_qwen_image_2_1_$workflow.json"
    mv "$destination.part" "$destination"
  fi
done
