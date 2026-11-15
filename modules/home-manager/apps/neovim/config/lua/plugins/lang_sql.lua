---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sqruff" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sql = { "sqruff" },
      },
    },
  },
}
