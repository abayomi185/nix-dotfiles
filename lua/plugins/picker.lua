local dap_prefix = "<Leader>fd"
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
    opts = function(_, opts)
      require("telescope").load_extension "live_grep_args"
      local actions = require "telescope.actions"
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = {
        i = {
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<PageUp>"] = actions.preview_scrolling_up,
          ["<PageDown>"] = actions.preview_scrolling_down,
          -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
          -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
          ["<Tab>"] = actions.move_selection_next,
          ["<S-Tab>"] = actions.move_selection_previous,
        },
      }
      return opts
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-dap.nvim",
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              [dap_prefix .. "c"] = {
                "<Cmd>lua require('telescope').extensions.dap.commands()<CR>",
                desc = "Telescope DAP commands",
              },
              [dap_prefix .. "f"] = {
                "<Cmd>lua require('telescope').extensions.dap.frames()<CR>",
                desc = "Telescope DAP frames",
              },
              [dap_prefix .. "g"] = {
                "<Cmd>lua require('telescope').extensions.dap.configurations()<CR>",
                desc = "Telescope DAP configurations",
              },
              [dap_prefix .. "l"] = {
                "<Cmd>lua require('telescope').extensions.dap.list_breakpoints()<CR>",
                desc = "Telescope DAP list breakpoints",
              },
              [dap_prefix .. "v"] = {
                "<Cmd>lua require('telescope').extensions.dap.variables()<CR>",
                desc = "Telescope DAP variables",
              },
            },
          },
        },
      },
    },
    opts = function() require("telescope").load_extension "dap" end,
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<c-u>"] = "preview_scroll_up",
              ["<c-d>"] = "preview_scroll_down",
            },
          },
          list = {
            keys = {
              ["<c-u>"] = "preview_scroll_up",
              ["<c-d>"] = "preview_scroll_down",
            },
          },
        },
      },
    },
  },
}
