-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = {
        enabled = function(bufnr, config) return config.lines > 10000 or config.size > 1024 * 500 end,
      }, -- set per buffer limit for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = { current_line = false, severity = { min = "HINT", max = "WARN" } },
      virtual_lines = { current_line = false, severity = { min = "ERROR" } },
      underline = true,
      severity_sort = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes:1", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
        -- cmdheight = 1, -- sets vim.opt.cmdheight
        -- updatetime = 25, -- sets vim.opt.updatetime
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        clipboard = vim.fn.has "wsl" == 1 and "win32yank" or nil, -- WSLg otherwise picks wl-copy
      },
      o = {
        hls = true, -- set highlight search
      },
    },
  },
}
