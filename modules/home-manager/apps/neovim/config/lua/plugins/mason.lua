-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        -- "lua-language-server",
        --
        -- install formatters
        -- "stylua",
        --
        -- install debuggers
        -- "debugpy",
        --
        -- install any other package
        -- "tree-sitter-cli",
      },
    },
  },
}
