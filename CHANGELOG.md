# What's new

What changed, and how to use it. Newest first; add an entry with each PR.

## 2026-11-15

### Try these
- **flash.nvim**: `s` + chars → jump to label; `S` → select a treesitter node (function, block…); in operator mode `r` acts remotely (e.g. `yr` → yank somewhere else without moving); `<C-s>` in `/` search toggles labels
- **ts-comments.nvim**: `gc`/`gcc` now pick the right comment style in TSX/JSX and other mixed-language files
- **Terminals (snacks)**: `<C-t>` / `<F7>` / `<C-'>` float, `<Leader>Th` / `<Leader>Tv` split, `<Leader>Tn` node, `<Leader>Tp` python, `<Leader>gg` lazygit
- **Pickers (snacks)**: `<Leader>fw` grep, `<Leader>bm` marks, `grr` references
- **`<Leader>y`** (visual) copies to the system clipboard, OSC52 over SSH, win32yank on WSL
- **Work profile**: `NVIM_PROFILE=work` (set by the work Nix flake) enables Copilot completions, jest/vitest tests, image.nvim, flake8, sqlfluff (MySQL), CloudFormation YAML tags, `<S-Space>` to leave terminal mode. See `lua/plugins/work.lua`

### Changed
- AstroNvim v6.1.1, rustaceanvim v9, blink.cmp v1; LuaSnip and DAP REPL completion back on
- Removed: none-ls (conform + nvim-lint instead), Telescope, toggleterm, codecompanion/opencode/other AI plugins, legendary, indent-blankline/hlchunk (snacks indent), nvim-notify, fidget, presence, nvim-osc52, lua-json5
