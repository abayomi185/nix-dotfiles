return {
  "obsidian-nvim/obsidian.nvim",
  -- the obsidian vault in this default config  ~/obsidian-vault
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  event = { "BufReadPre  */iCloud~md~obsidian/*.md" },

  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["gf"] = {
              function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<Cmd>Obsidian follow_link<CR>"
                else
                  return "gf"
                end
              end,
              desc = "Obsidian Follow Link",
            },
          },
        },
      },
    },
  },
  ---@param _ LazyPlugin
  ---@param opts obsidian.config
  opts = function(_, opts)
    local astrocore = require "astrocore"
    return astrocore.extend_tbl(opts, {
      legacy_commands = false,
      ui = { enable = false }, -- render-markdown handles rendering
      callback = {
        enter_note = function(note)
          vim.ui.open = (function(overridden)
            return function(uri, opt)
              if vim.endswith(uri, ".png") then
                vim.cmd("edit " .. uri) -- early return to just open in neovim
                return
              elseif vim.endswith(uri, ".pdf") then
                opt = { cmd = { "zathura" } } -- override open app
              end
              return overridden(uri, opt)
            end
          end)(vim.ui.open)
        end,
      },
      workspaces = {
        {
          -- specify the vault location. no need to call 'vim.fn.expand' here
          path = vim.env.HOME .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Life",
        },
      },
      open = {
        use_advanced_uri = true,
      },
      finder = (astrocore.is_available "snacks.pick" and "snacks.pick")
        or (astrocore.is_available "telescope.nvim" and "telescope.nvim")
        or (astrocore.is_available "fzf-lua" and "fzf-lua")
        or (astrocore.is_available "mini.pick" and "mini.pick"),

      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },
      attachment = {
        folder = "!assets",
      },
      daily_notes = {
        folder = "daily",
      },
      completion = {
        blink = astrocore.is_available "blink",
        nvim_cmp = false,
      },
      frontmatter = {
        func = function(note)
          -- This is equivalent to the default frontmatter function.
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
      },

      follow_url_func = vim.ui.open,
    })
  end,
}
