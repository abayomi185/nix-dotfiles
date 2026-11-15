-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }

-- DAP
-- local dap = require "dap"
-- dap.adapters.debugpy = dap.adapters.python

-- NOTE: This is a global function
P = function(v)
  print(vim.inspect(v))
  return v
end

PB = function(v)
  vim.cmd "new"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.inspect(v), "\n"))
end

-- Set spell checking for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.spell = true end,
})

-- NOTE: Macros - 'quote' a word
vim.api.nvim_set_keymap("n", "qw", ":silent! normal mpea'<Esc>bi'<Esc>`pl<CR>", { noremap = true })
-- Double "quote" a word
vim.api.nvim_set_keymap("n", "qd", ':silent! normal mpea"<Esc>bi"<Esc>`pl<CR>', { noremap = true })
-- Remove quotes from a word
vim.api.nvim_set_keymap("n", "wq", ":silent! normal mpeld bhd `ph<CR>", { noremap = true })

-- Keep highlight after search
vim.on_key(function() end, vim.api.nvim_get_namespaces()["auto_hlsearch"])

-- NOTE: DAP
-- Associate filetypes with debug adapters
require("dap.ext.vscode").type_to_filetypes = { rt_lldb = { "rust" }, ["probe-rs-debug"] = { "rust" } }

-- Debugpy adapter for dap needs to be set
local dap = require "dap"

dap.adapters.debugpy = dap.adapters.python
