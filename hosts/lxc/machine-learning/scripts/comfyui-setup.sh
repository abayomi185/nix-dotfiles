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

# Video models. Each line: sha256, path under models/, Hugging Face repo, path in repo.
# Downloads resume and existing files are kept; every file is then checksum-verified.
fetch_verified() {
  while read -r sha path repo src; do
    destination="$comfy_dir/models/$path"
    mkdir -p "$(dirname "$destination")"
    if [ ! -f "$destination" ]; then
      curl --fail --location --retry 5 --continue-at - \
        --output "$destination.part" "https://huggingface.co/$repo/resolve/main/$src"
      mv "$destination.part" "$destination"
    fi
    echo "$sha  $destination"
  done | sha256sum --check
}

wan=Comfy-Org/Wan_2.2_ComfyUI_Repackaged
h3=Comfy-Org/MiniMax-H3
fetch_verified <<MODELS
c3355d30191f1f066b26d93fba017ae9809dce6c627dda5f6a66eaa651204f68 text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors $wan split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
2fc39d31359a4b0a64f55876d8ff7fa8d780956ae2cb13463b0223e15148976b vae/wan_2.1_vae.safetensors $wan split_files/vae/wan_2.1_vae.safetensors
6122e79d55e0f235698d11d657f3b196c5273c830da00b2b013c5a048d5e6a42 diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors $wan split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors
5471a457b6ac404202a5fbe6c11595a3d5641fc766b00f38763f72303fffc21e diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors $wan split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors
d176c808d6fc461999b68e321efcb7501b20b8c3797523ed0df14f7d1deff11e loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors $wan split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors
024f21de095bc8fad9809ded3e9e49a2e170dcf27075da8145ba7d60d8aab7f9 loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors $wan split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors
e889202c41dafb67b10d67b97f0d8541508036a6090af23425a5c2615d03c47a diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors $h3 diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors
35a88d51044231fe332301d7a62aa81e3f2cba62febeb446e2c1e3e0ef76f2c6 text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors $h3 text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors
52a2c8c73583c86e4f41cdcce3a6ad0ea562987bc0bf3d60a0cef5f5c8e60c0e vae/minimax_h3_video_vae_int8_convrot.safetensors $h3 vae/minimax_h3_video_vae_int8_convrot.safetensors
8e505d95dd1561d47abd43d4238fd40d9bb1ae9e147ed0a4cba778d76ae4db48 vae/minimax_h3_audio_vae_fp32.safetensors $h3 vae/minimax_h3_audio_vae_fp32.safetensors
2339acdf19bfe123f46b971ea35d367a84adb85de43627e1eceafa5a5b2b111e loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors $h3 loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors
MODELS

video_workflow_rev=ff15d86b5a143d546ed632826d72501298563ddb
for workflow in video_minimax_h3_i2v video_wan2_2_14B_i2v; do
  destination="$comfy_dir/user/default/workflows/$workflow.json"
  if [ ! -f "$destination" ]; then
    curl --fail --location --retry 5 --output "$destination.part" \
      "https://raw.githubusercontent.com/Comfy-Org/workflow_templates/$video_workflow_rev/templates/$workflow.json"
    mv "$destination.part" "$destination"
  fi
done
