# machine-learning llama-server

## Current managed service

The machine-learning host runs `llama-server` as a Home Manager user service named `llama-server`.
The current managed setup is the source of truth, not the older one-off benchmark commands below.

- bind: `0.0.0.0:9000`
- auth: `--api-key-file /home/ml/.config/llama-server/api-keys`
- preset source: `hosts/lxc/machine-learning/configs/llama-models.ini`
- web UI: disabled
- metrics: enabled

Current presets:

- `unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL`
- `unsloth/gpt-oss-20b-GGUF:F16`

The managed tuning currently comes from `hosts/lxc/machine-learning/configs/llama-models.ini`:

- `parallel = 1`
- `threads = 32`
- `threads-batch = 32`
- `mlock = true`
- Qwen3.6 preset: `fit-target = 512`, `flash-attn = on`, `cache-type-k/v = q8_0`, `batch-size = 2048`, `ubatch-size = 2048`
- GPT OSS 20B preset: `fit-target = 512`, `flash-attn = on`, `jinja = true`, `batch-size = 2048`, `ubatch-size = 512`

## Checking the current API key

`llama-server` reads one non-empty API key per line from:

```bash
~/.config/llama-server/api-keys
```

Print the currently active key on the host:

```bash
cat ~/.config/llama-server/api-keys
```

`/v1/models` is intentionally public in llama.cpp, so it is useful for discovery but not for auth verification.

To verify auth enforcement, hit a protected endpoint without a token and expect `401`:

```bash
curl http://127.0.0.1:9000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL","prompt":"hi","max_tokens":1}'
```

## Rotating the API key

Generate a new key, replace the file atomically, and restart the user service:

```bash
umask 077
mkdir -p ~/.config/llama-server
openssl rand -base64 48 | tr -d '\n' > ~/.config/llama-server/api-keys.tmp
printf '\n' >> ~/.config/llama-server/api-keys.tmp
mv ~/.config/llama-server/api-keys.tmp ~/.config/llama-server/api-keys
chmod 600 ~/.config/llama-server/api-keys
systemctl --user restart llama-server
```

Verify the restarted service and confirm auth is being enforced:

```bash
systemctl --user status llama-server --no-pager
curl http://127.0.0.1:9000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL","prompt":"hi","max_tokens":1}'
# Expect HTTP 401
```

Then send the same request with the bearer token. In router mode with `--no-models-autoload`, a successful auth check may still return a model-state error such as `400 model is not loaded`; the important part is that it is no longer `401 Invalid API Key`.

```bash
curl http://127.0.0.1:9000/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(< ~/.config/llama-server/api-keys)" \
  -d '{"model":"unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL","prompt":"hi","max_tokens":1}'
```

If the Home Manager config has not been applied on the host yet, apply it first from the repo root:

```bash
nix --extra-experimental-features "nix-command flakes" run nixpkgs#home-manager -- \
  --extra-experimental-features "nix-command flakes" switch --flake .#ml@machine-learning
```

## Ad hoc single-model benchmark commands

These were the benchmark baselines used to tune the managed presets. They are useful for temporary manual runs, but they are not the current managed router service.

### Best general single-user thinking/coding server

```bash
llama-server \
  -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL \
  --fit on \
  --fit-ctx 131072 \
  --fit-target 512 \
  -np 1 \
  -t 32 \
  -tb 32 \
  -fa on \
  -ctk q8_0 \
  -ctv q8_0 \
  -b 2048 \
  -ub 2048 \
  --mlock \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.0 \
  --presence-penalty 0.0 \
  --repeat-penalty 1.0 \
  --host 0.0.0.0 \
  --port 8080
```

### Same server, but non-thinking mode

```bash
llama-server \
  -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL \
  --fit on \
  --fit-ctx 131072 \
  --fit-target 512 \
  -np 1 \
  -t 32 \
  -tb 32 \
  -fa on \
  -ctk q8_0 \
  -ctv q8_0 \
  -b 2048 \
  -ub 2048 \
  --mlock \
  --reasoning-budget 0 \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.0 \
  --presence-penalty 1.5 \
  --repeat-penalty 1.0 \
  --host 0.0.0.0 \
  --port 8080
```

### Long-prompt variant

Use `-b 4096 -ub 4096` only if your real workload is consistently 4K+ token prompt ingestion. It improved prompt processing throughput, but did not improve generation speed and was slightly worse on smaller prompts.

## Tuning conclusions

For this host, the benchmarked defaults that held up were:

- `--fit-target 512`
- `-np 1`
- `-t 32 -tb 32`
- `-fa on`
- `-ctk q8_0 -ctv q8_0`
- `-b 2048 -ub 2048`
- `--mlock`

For Qwen mode control:

- use `--reasoning-budget 0` or per-request `enable_thinking: false`
- do not rely on `preserve_thinking` unless you have validated the template behavior yourself