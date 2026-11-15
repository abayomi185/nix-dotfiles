---@type LazySpec
return {
  {
    "olimorris/onedarkpro.nvim",
    -- priority = 1000,
    opts = {
      highlights = {
        LspReferenceText = { underline = true },
      },
      colors = {
        dark = {
          cursorline = "#22252b",
          inlay_hint = "#616976",
        },
        light = {
          cursorline = "#e0e0d6",
          bg = "#e6e6df",
          inlay_hint = "#a2a2a2",
          yellow = "#ed8b1b",
        },
      },
      options = {
        cursorline = true,
      },
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 60 * 1000,
      set_dark_mode = function()
        -- vim.api.nvim_set_option("background", "dark")
        vim.cmd "colorscheme onedark"
      end,
      set_light_mode = function()
        -- vim.api.nvim_set_option("background", "light")
        vim.cmd "colorscheme onelight"
      end,
    },
  },
}
