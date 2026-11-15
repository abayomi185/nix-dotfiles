-- Customize Treesitter

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        highlight = true, -- enable/disable treesitter based highlighting
        indent = true, -- enable/disable treesitter based indentation
        auto_install = true, -- enable/disable automatic installation of detected languages
        ensure_installed = {
          "lua",
          "vim",
          "html", -- used by render-markdown
          "dap_repl", -- registered by nvim-dap-repl-highlights
          -- add more arguments for adding more treesitter parsers
        },
      },
    },
  },
  -- NOTE: Repl highlights
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "LiadOz/nvim-dap-repl-highlights",
      dependencies = { "mfussenegger/nvim-dap" },
      opts = {},
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    event = "User AstroFile",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
    },
  },
}
