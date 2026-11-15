local prefix = "<Leader>m"

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.commands = {
        AddMarkdownHeader = {
          function()
            local date = tostring(os.date "### %Y-%m-%d")
            local cursor = vim.api.nvim_win_get_cursor(0)
            local row = cursor[1] - 1
            vim.api.nvim_buf_set_lines(0, row, row, false, { date, "" })
          end,
          -- the rest are options for creating user commands (:h nvim_create_user_command)
          desc = "Add Markdown header with current date",
        },
      }

      local maps = opts.mappings

      -- Markdown mappings
      maps.n[prefix] = { desc = "󰍔 Markdown" }
      maps.n[prefix .. "b"] = {
        function()
          local lines = { "```", "", "```" }
          vim.api.nvim_put(lines, "l", true, true)
          vim.cmd "normal! k"
        end,
        desc = "Insert code block",
      }
      maps.n[prefix .. "c"] = {
        function() vim.api.nvim_put({ "- [ ] " }, "c", true, true) end,
        desc = "Insert checkbox",
      }
      maps.n[prefix .. "l"] = {
        function() vim.api.nvim_put({ "[link text](url)" }, "c", true, true) end,
        desc = "Insert link",
      }
      maps.v[prefix .. "l"] = {
        function()
          -- Use substitute to wrap selection in link format
          vim.cmd "'<,'>s/\\%V.*\\%V./[&](url)/"

          -- Position cursor at 'url' for easy replacement
          vim.cmd "normal! `<f(lviw" -- Go to start, find (, move right, select 'url'
        end,
        desc = "Wrap selection in link",
      }
      maps.n[prefix .. "a"] = {
        function() vim.api.nvim_put({ "![alt text](image_url)" }, "c", true, true) end,
        desc = "Insert image",
      }

      -- Headings
      maps.n[prefix .. "h"] = { desc = "Markdown Headings" }
      maps.n[prefix .. "hh"] = {
        function() vim.api.nvim_put({ "# " }, "c", true, true) end,
        desc = "Insert Heading 1",
      }
      maps.n[prefix .. "h2"] = {
        function() vim.api.nvim_put({ "## " }, "c", true, true) end,
        desc = "Insert Heading 2",
      }
      maps.n[prefix .. "h3"] = {
        function() vim.api.nvim_put({ "### " }, "c", true, true) end,
        desc = "Insert Heading 3",
      }
      maps.n[prefix .. "h4"] = {
        function() vim.api.nvim_put({ "#### " }, "c", true, true) end,
        desc = "Insert Heading 4",
      }
      maps.n[prefix .. "h5"] = {
        function() vim.api.nvim_put({ "##### " }, "c", true, true) end,
        desc = "Insert Heading 5",
      }

      maps.n[prefix .. "i"] = { desc = "Markdown items" }
      maps.n[prefix .. "ii"] = {
        function() vim.api.nvim_put({ "- " }, "c", true, true) end,
        desc = "Insert item",
      }
      maps.n[prefix .. "ic"] = {
        function() vim.api.nvim_put({ "- [ ] " }, "c", true, true) end,
        desc = "Insert checkbox",
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- "echasnovski/mini.nvim", -- if you use the mini.nvim suite
      -- 'echasnovski/mini.icons' -- if you use standalone mini plugins
      "nvim-tree/nvim-web-devicons",
    },
    opts = { latex = { enabled = false } },
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = { filetypes = { extension = {
      mdx = "markdown.mdx",
    } } },
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = {
      config = {
        mdx_analyzer = {
          init_options = {
            typescript = {
              enabled = true,
            },
          },
        },
      },
    },
  },
  {
    "davidmh/mdx.nvim",
    event = "BufEnter *.mdx",
    config = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
