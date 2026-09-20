# ComfyUI on machine-learning

ComfyUI runs as the `ml` user's systemd service on the Ubuntu host, using its
RTX 3090. Home Manager owns the service and helper commands. The checkout,
Python environment, models, workflows and generated images live under
`/home/ml/ComfyUI`, outside the Nix store.

- UI: <https://comfyui.local.yomitosh.media>
- Direct LAN access: <http://machine-learning.internal.yomitosh.media:8188>
- llama.cpp UI: <https://llm.local.yomitosh.media>
- llama.cpp OpenAI-compatible API: <https://llm.local.yomitosh.media/v1>

The HTTPS routes live in `home-ops/apps/base/productivity/machine-learning`.
Traefik resolves the host's internal DNS name using ExternalName services.
An IP allowlist restricts these routes to the native, infrastructure and main
LANs, cluster backplane and WireGuard. No public-domain route is configured.
ComfyUI has no application login; llama.cpp retains its existing API key.

## Install and update

Apply this host's Home Manager configuration, then run as `ml`:

```sh
comfyui-setup
systemctl --user enable --now comfyui
```

The setup script pins ComfyUI to commit
`c194dd00cd42aa18d9dbf27d977bf6b85d9ea565`, which includes native Qwen-Image-2.1
support. It installs CUDA 13.0 PyTorch wheels into a Python 3.12 environment.
It resumes interrupted model downloads and preserves existing model files and
saved workflows. Stop ComfyUI before changing its Python environment.

The initial deployment installed the evaluated systemd unit directly to avoid
rebuilding the existing llama.cpp package. On the first full Home Manager
switch, use `-b backup` if it reports the unit or GPU helper as an existing file.

## Qwen-Image-2.1

The official INT8 weights total about 17.3 GB:

| Directory under `ComfyUI/models` | File |
| --- | --- |
| `diffusion_models` | `qwen_image_2.1_int8_convrot.safetensors` |
| `text_encoders` | `qwen3vl_8b_int8_convrot.safetensors` |
| `vae` | `qwen_image_2.1_vae_bf16.safetensors` |

Open the Qwen-Image-2.1 text-to-image or edit workflow in the Workflows sidebar.
The built-in template library also includes both. Start with the official
settings: 1024 × 1024, 25 steps, CFG 1, Euler sampler and simple scheduler.
Image editing uses the same three model files. No custom nodes are required.

Sources: [model files](https://huggingface.co/Comfy-Org/Qwen-Image-2.1),
[official workflows](https://github.com/Comfy-Org/workflow_templates),
[ComfyUI installation](https://github.com/Comfy-Org/ComfyUI#manual-install-windows-linux).

## Share the GPU with llama.cpp

The language model can occupy almost all 24 GB of VRAM. Run one inference
service at a time. From your Mac:

```sh
# Stops llama.cpp and starts ComfyUI.
ssh ml@machine-learning.internal.yomitosh.media '~/.local/bin/ml-gpu comfyui'

# Stops ComfyUI and starts llama.cpp.
ssh ml@machine-learning.internal.yomitosh.media '~/.local/bin/ml-gpu llama'
```

These switches stop the other service, including active requests. Complete any
queued work first. Both units are enabled at boot; starting ComfyUI alone does
not load Qwen weights. Choose the GPU mode before submitting a workflow.

```sh
systemctl --user status comfyui
journalctl --user -u comfyui -f
nvidia-smi
```

Models consume substantial disk space. Check `df -h /home` before adding more.
The setup does not delete existing models or Hugging Face caches.

## Deployment validation

On 2026-09-20, the RTX 3090 completed a 1024 × 1024 text-to-image workflow at
25 steps in 38.18 seconds, including initial model loading. The output is
`ComfyUI/output/Qwen-Image-2.1-setup-test_00001_.png`. Both HTTPS routes were
checked with certificate verification enabled. Home-ops PR #336 supplies the
Flux-managed routes.
