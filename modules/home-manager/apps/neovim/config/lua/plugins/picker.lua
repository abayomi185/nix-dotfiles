---@type LazySpec
return {
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
