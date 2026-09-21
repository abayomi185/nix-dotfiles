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
Image editing uses the same three model files. The generation workflows use
only built-in nodes. AutoFreeMemory is a separate background extension.

## Profile pictures from reference photos

Three editable presets are seeded into the Workflows sidebar by Home Manager:

- `Qwen-2.1-LinkedIn-headshot`: one photo, neutral studio setting and blazer.
- `Qwen-2.1-Instagram-profile`: one photo, casual outdoor portrait.
- `Qwen-2.1-Profile-three-references`: three photos of the same person,
  with the first photo as the primary identity reference.

These are local adaptations of the official Comfy-Org editing template at
commit `371a7b7171bbd11e9cc92ef615ba5ad223d7e5b4`, not independently reviewed
community workflows. They use the installed INT8 models and 1024-square
output, with space for circular avatar cropping.

Replace the demo portrait in each Load Image node with your own photo, edit
the prompt if desired, then click Run. Use clear, unfiltered photos with the
face visible. For the three-reference preset, use different angles of the
same person. All processing happens on the machine-learning host.

Likeness is approximate. Inspect facial features and skin texture before
using the output. The bundled demo is an official Comfy-Org sample, not a
photo of the user. Home Manager seeds missing presets without overwriting
edits saved in the UI.

## Idle unloading

llama.cpp uses its native `--sleep-idle-seconds 3600` flag for a one-hour timeout, inherited by models
started through the router. It releases model and KV-cache memory after
inactivity and reloads on the next inference request. Health, props, models
and metrics queries do not reset the timer.

ComfyUI uses [AutoFreeMemory](https://github.com/Nlepetit/ComfyUI-AutoFreeMemory)
at commit `a00d3a6827128c33c81556ba10972b2348f3ab2c`. It has no extra Python
dependencies. After the running and pending queues stay empty for 300 seconds,
it requests ComfyUI's native model and execution-cache unload. Its three-second
poll interval means unloading may occur a few seconds after the deadline.
The web interface stays available, and the next generation reloads the models.

Change the ComfyUI delay under **Settings > AutoFreeMemory**. The setup script
seeds the UI setting to 300 seconds, preserving subsequent user changes.
Environment variables provide defaults if the settings file is absent.

Idle unloading does not arbitrate simultaneous requests. Wait for the other
service to sleep, unload it manually, or use the explicit GPU switch below.
The first generation after unloading pays the model-loading cost again.

Source: [llama.cpp sleeping on idle](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md#sleeping-on-idle).

## Community workflows and alternative engines

Checked on 2026-09-20:

- [Civitai Qwen 2.1 workflow collection](https://civitai.com/models/579280?modelVersionId=3343677):
  the new native-accelerator version had 14 downloads and 6 likes. The much
  larger collection totals include other models and versions. The download
  returned HTTP 403, so its graph was not audited or installed.
- [Face-replicator with Qwen Edit 2509](https://civitai.com/models/2087176):
  3,662 downloads and 196 likes, but marked discontinued and targets the older
  2509 model. Its dependencies are not a drop-in replacement for Qwen 2.1.

llama.cpp does not provide the Qwen-Image-2.1 diffusion pipeline. The related
[stable-diffusion.cpp project supports Qwen 2.1](https://github.com/leejet/stable-diffusion.cpp/blob/master/docs/qwen_image_2.1.md),
including image editing with repeated reference-image arguments. It supports
GGUF weights and several compute backends, and suits scripts or embedded use
without the ComfyUI Python environment. It is a separate engine and service.

ComfyUI is the default here because it already works on the RTX 3090, provides
reference uploads and previews, and saves editable workflows with the output.
There is no measured speed comparison for this host. Engine-specific settings
and quantizations can change performance and image quality.

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

The profile presets were verified in the browser on the same date. The
single-reference graph completed in 48.47 seconds; the three-reference graph
completed in 43.50 seconds using the bundled sample in all three slots. This
checks the multi-image pipeline, not likeness across different personal photos.
The Instagram preset was opened and its graph validated, without a separate
generation. llama.cpp entered sleep 300 seconds after its test request.
ComfyUI requested its automatic full unload 301 seconds after the last job,
reducing total GPU usage from 16,731 MiB to 705 MiB with both services still
active. The test did not call the manual free endpoint or stop either service.
