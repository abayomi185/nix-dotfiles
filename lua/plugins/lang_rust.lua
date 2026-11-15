local prefix = "<Leader>r"

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings

      -- Rust mappings
      maps.n[prefix] = { desc = "󱘗 Rust" }
      maps.n[prefix .. "e"] = { "<cmd>RustLsp expandMacro<Cr>", desc = "Expand Macro" }
      maps.n[prefix .. "g"] = { "<cmd>RustLsp crateGraph<Cr>", desc = "Expand Macro" }
      maps.n[prefix .. "o"] = { "<cmd>RustLsp openCargo<Cr>", desc = "Expand Macro" }
      maps.n[prefix .. "d"] = { "<cmd>RustLsp openDocs<Cr>", desc = "Expand Macro" }
      maps.n[prefix .. "r"] = { "<cmd>RustLsp reloadWorkspace<Cr>", desc = "Expand Macro" }
      maps.n[prefix .. "l"] = { "<cmd>RustLsp explainError<Cr>", desc = "Expand Macro" }
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = {
      handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
      ---@diagnostic disable: missing-fields
      config = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              -- checkOnSave = true, --defaults to true
              assist = {
                importEnforceGranularity = true,
                importPrefix = "crate",
              },
              completion = {
                postfix = {
                  enable = false,
                },
              },
              inlayHints = {
                lifetimeElisionHints = {
                  enable = true,
                  useParameterNames = true,
                },
              },
              files = {
                excludeDirs = {
                  ".direnv",
                  ".git",
                  "target",
                },
              },
              runnables = {
                -- extraArgs = {},
                -- extraTestBinaryArgs = {
                --   "--show-output",
                -- },
              },
            },
          },
        },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    ft = "rust",
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
        },
      },
    },
    opts = function()
      local adapter
      local success, package = pcall(function() return require("mason-registry").get_package "codelldb" end)
      local cfg = require "rustaceanvim.config"

      local this_os = vim.uv.os_uname().sysname

      local code_lldb_path = vim.fn.getenv "CODE_LLDB_PATH"
      local lib_lldb_path = vim.fn.getenv "LIB_LLDB_PATH"

      if code_lldb_path and lib_lldb_path then
        lib_lldb_path = lib_lldb_path .. (this_os == "Linux" and ".so" or ".dylib")

        adapter = cfg.get_codelldb_adapter(code_lldb_path, lib_lldb_path)
      elseif success then
        local package_path = package:get_install_path()
        local codelldb_path = package_path .. "/codelldb"
        local liblldb_path = package_path .. "/extension/lldb/lib/liblldb"

        -- The path in windows is different
        if this_os:find "Windows" then
          codelldb_path = package_path .. "\\extension\\adapter\\codelldb.exe"
          liblldb_path = package_path .. "\\extension\\lldb\\bin\\liblldb.dll"
        else
          -- The liblldb extension is .so for linux and .dylib for macOS
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      else
        adapter = cfg.get_codelldb_adapter()
      end

      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts "rust_analyzer") or {}
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_opts.settings or {})
          -- applies rustaceanvim defaults (e.g. clippy); project settings files are no longer read since v8
          return require("rustaceanvim.config.server").load_rust_analyzer_settings(project_root, {
            default_settings = merge_table,
          })
        end,
      }
      local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)

      return {
        server = final_server,
        dap = { adapter = adapter, load_rust_types = true },
        tools = {
          --   autoSetHints = true,
          --   runnables = {
          --     use_telescope = true,
          --   },
          -- enable_clippy = false,
        },
      }
    end,
    config = function(_, opts) vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim) end,
  },
  {
    "Saecki/crates.nvim",
    lazy = true,
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = { enabled = true },
      },
      lsp = {
        enabled = true,
        on_attach = function(...) require("astrolsp").on_attach(...) end,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      local rustaceanvim_avail, rustaceanvim = pcall(require, "rustaceanvim.neotest")
      if rustaceanvim_avail then table.insert(opts.adapters, rustaceanvim) end
    end,
  },
}
