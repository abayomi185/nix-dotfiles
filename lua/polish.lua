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

local function addPythonPathToDapConfigs(configurations, venv_path)
  if not venv_path then return end
  for _, config in ipairs(configurations) do
    if (config.type == "python" or config.type == "debugpy") and config.pythonPath == nil then
      local pathSuffix = vim.fn.has "win32" == 1 and "/Scripts/python" or "/bin/python"
      config.pythonPath = venv_path .. pathSuffix
    end
  end
end

function _G.dump_lsp_config_to_buffer()
  -- Capture the output of the Lua command
  local output = vim.inspect(vim.lsp.config.yamlls)

  -- Create a new buffer
  vim.cmd "new"

  -- Get the buffer number of the new buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- Insert the output into the new buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(output, "\n"))
end

-- Bind the function to a command
vim.cmd "command! DumpLSPConfig lua dump_lsp_config_to_buffer()"

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

-- Copilot colour
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

-- Keep highlight after search
vim.on_key(function() end, vim.api.nvim_get_namespaces()["auto_hlsearch"])

-- NOTE: DAP
-- Load launch.json
require("dap.ext.vscode").json_decode = require("json5").parse

-- Associate filetypes with debug adapters
require("dap.ext.vscode").type_to_filetypes = { rt_lldb = { "rust" }, ["probe-rs-debug"] = { "rust" } }

-- Debugpy adapter for dap needs to be set
local dap = require "dap"

dap.adapters.debugpy = dap.adapters.python

-- Seemingly not needed anymore as seen in work branch
-- dap.adapters.debugpy = dap.adapters.python
-- addPythonPathToDapConfigs(dap.configurations.python, os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX")
