-- Work-only setup, active when NVIM_PROFILE=work (set by the work Nix flake).
-- New plugins use `enabled` (not import `cond`) so lazy-lock.json keeps their pins on every machine.
local is_work = vim.env.NVIM_PROFILE == "work"

---@type LazySpec
local specs = {
  {
    "zbirenbaum/copilot.lua",
    enabled = is_work,
    cmd = "Copilot",
    event = "User AstroFile",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = { yaml = true },
      copilot_node_command = vim.env.COPILOT_NODE or "node", -- pinned by Nix; fnm may switch `node` per project
    },
  },
  { "giuxtaposition/blink-cmp-copilot", enabled = is_work, lazy = true },
  { "nvim-neotest/neotest-jest", enabled = is_work, lazy = true },
  { "marilari88/neotest-vitest", enabled = is_work, lazy = true },
  { "nvimtools/none-ls-extras.nvim", enabled = is_work, lazy = true },
  {
    "3rd/image.nvim",
    enabled = is_work,
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- luarocks is disabled, so use the ImageMagick CLI
      integrations = {
        markdown = { enabled = true, download_remote_images = true, filetypes = { "markdown", "vimwiki" } },
        neorg = { enabled = true, download_remote_images = true, filetypes = { "norg" } },
      },
      max_height_window_percentage = 50,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
    },
  },
}

if not is_work then return specs end

-- Overrides of shared plugins: only added at work
return vim.list_extend(specs, {
  {
    "Saghen/blink.cmp",
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = { name = "copilot", module = "blink-cmp-copilot", score_offset = 100, async = true },
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      formatting = { timeout_ms = 4000 },
      config = {
        -- one vtsls per repo so monorepo packages share a server
        vtsls = { root_dir = function(bufnr, on_dir) on_dir(vim.fs.root(bufnr, ".git")) end },
        -- CloudFormation intrinsic functions
        yamlls = {
          settings = {
            yaml = {
              customTags = {
                "!And",
                "!And sequence",
                "!Base64",
                "!Cidr",
                "!Condition scalar",
                "!Equals",
                "!Equals sequence",
                "!FindInMap sequence",
                "!fn",
                "!GetAtt",
                "!GetAtt scalar",
                "!GetAZs",
                "!If",
                "!If sequence",
                "!ImportValue",
                "!ImportValue scalar",
                "!ImportValue sequence",
                "!Join sequence",
                "!Not",
                "!Not sequence",
                "!Or",
                "!Or sequence",
                "!Ref",
                "!Ref Scalar",
                "!Select",
                "!Split",
                "!Sub",
                "!Sub scalar",
                "!Sub sequence",
              },
            },
          },
        },
        snyk_ls = {
          init_options = {
            activateSnykCode = "true",
            trustedFolders = { "/home/test/projek" },
            enableTelemetry = "false",
            sendErrorReports = "false",
          },
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require "null-ls"
      opts.sources = {
        null_ls.builtins.formatting.sqlfluff.with { filetypes = { "sql" }, extra_args = { "--dialect", "mysql" } },
        null_ls.builtins.formatting.alejandra.with { filetypes = { "nix" } },
        null_ls.builtins.formatting.black.with { filetypes = { "python" } },
        null_ls.builtins.formatting.isort.with { filetypes = { "python" }, extra_args = { "--profile", "black" } },
        require("none-ls.diagnostics.eslint").with {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
        },
        require("none-ls.diagnostics.flake8").with {
          filetypes = { "python" },
          extra_args = {
            "--format",
            "default",
            "--stdin-display-name",
            "$FILENAME",
            "-",
            "--count",
            "--max-line-length",
            "115",
            "--exclude=snapshots",
          },
        },
      }
    end,
  },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      local plugin_opts = require("astrocore").plugin_opts
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require "neotest-jest"(plugin_opts "neotest-jest"))
      table.insert(opts.adapters, require "neotest-vitest"(plugin_opts "neotest-vitest"))
    end,
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = { mappings = { t = { ["<S-Space>"] = "<C-\\><C-n>" } } },
  },
})
