---

Final recommended llama-server commands

1.  Best general single-user thinking/coding server

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

2.  Same server, but non-thinking mode

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

3.  Long-prompt variant, if you regularly send 4K+ token prompts

From earlier benches:

- -b 4096 -ub 4096 improved pp4096
- it did not improve generation
- it was slightly worse at smaller prompt sizes

So only use this if your real workload is consistently long-context prompt ingestion:

```bash
  -b 4096 -ub 4096
```

What I would not use

- -np auto
- -np 2 for your single-user case
- -tb 64
- --fit-target 256
- manual --n-cpu-moe
- undocumented preserve_thinking as a production default

Bottom line

For your box, the best server config is:

- --fit-target 512
- -np 1
- -t 32 -tb 32
- -fa on
- -ctk q8_0 -ctv q8_0
- -b 2048 -ub 2048
- --mlock

And for Qwen mode control:

- use --reasoning-budget 0 or per-request enable_thinking: false
- do not rely on preserve_thinking unless you want to validate custom template
  behavior yourself

All test servers were stopped after benchmarking.

If you want, I can now start the recommended llama-server on the host with your
preferred mode:

- thinking/coding
- non-thinking/general
- long-prompt optimized
