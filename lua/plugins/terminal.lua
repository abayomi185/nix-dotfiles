local prefix = "<Leader>T"

local function term(cmd, position)
  return function() require("snacks").terminal.toggle(cmd, { win = { position = position or "float" } }) end
end

---@type LazySpec
return {
  { "akinsho/toggleterm.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = { terminal = { win = { border = "rounded" } } },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n[prefix] = { desc = " Terminal" }

          if vim.fn.executable "lazygit" == 1 then
            local lazygit = function()
              local worktree = require("astrocore").file_worktree()
              local args = worktree and { "--work-tree=" .. worktree.toplevel, "--git-dir=" .. worktree.gitdir } or nil
              require("snacks").lazygit { args = args }
            end
            maps.n["<Leader>gg"] = { lazygit, desc = "Lazygit" }
            maps.n[prefix .. "l"] = { lazygit, desc = "Lazygit" }
          end
          for key, cmd in pairs { n = "node", p = "python3", t = "btm", u = "gdu-go" } do
            if vim.fn.executable(cmd) == 1 then maps.n[prefix .. key] = { term(cmd), desc = "Terminal " .. cmd } end
          end
          maps.n[prefix .. "f"] = { term(), desc = "Terminal float" }
          maps.n[prefix .. "h"] = { term(nil, "bottom"), desc = "Terminal horizontal split" }
          maps.n[prefix .. "v"] = { term(nil, "right"), desc = "Terminal vertical split" }

          for _, key in ipairs { "<C-t>", "<F7>", "<C-'>" } do
            for _, mode in ipairs { "n", "t", "i" } do
              maps[mode][key] = { term(), desc = "Toggle terminal" }
            end
          end
          for _, key in ipairs { "<C-l>", "<C-k>" } do
            for _, mode in ipairs { "t", "i" } do
              maps[mode][key] = { term(), desc = "Toggle terminal" }
            end
          end
        end,
      },
    },
  },
}
