---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- PASSED: Normal Mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs with `H` and `L`
        L = {
          function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
          desc = "Next buffer",
        },
        H = {
          function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
          desc = "Previous buffer",
        },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },

        -- NOTE: Save
        ["<M-s>"] = { ":w<cr>", desc = "Save File" }, -- change description but the same command
        ["<Leader>W"] = { "<cmd>lua saveWithoutFormatting()<CR>", desc = "Save without formatting" },

        -- Terminal
        -- ["<C-t>"] = { "<cmd>ToggleTerm direction=float<CR>", desc = "ToggleTerm float" }, -- This is defined in ./toggleterm.lua

        ["<Leader>h"] = { ":nohlsearch<cr>", desc = "No Highlight" },

        -- NOTE: Git Diff
        ["<Leader>gd"] = { ":DiffviewOpen<cr>", desc = "Open Diff View" },
        ["<Leader>gD"] = { ":DiffviewClose<cr>", desc = "Close Git Diff" },

        -- NOTE: Git Signs
        ["<Leader>gn"] = { ":Gitsigns nav_hunk next<CR>", desc = "Next Hunk" },
        ["<Leader>gN"] = { ":Gitsigns nav_hunk prev<CR>", desc = "Previous Hunk" },

        -- Move line
        ["<M-j>"] = ":m .+1<CR>==",
        ["<M-k>"] = ":m .-2<CR>==",

        ["<Leader>v"] = { "<C-v>", desc = "Visual Block" },

        ["<Leader>bm"] = { function() require("snacks").picker.marks() end, desc = "Find marks" },

        -- NOTE: Custom workaround for vertical resize on macOS
        ["<C-M-l>"] = ":vertical resize -2<CR>",
        ["<C-M-h>"] = ":vertical resize +2<CR>",

        -- NOTE: LSP mappings
        ["gh"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Show hover" },

        -- NOTE: Debug Mappings
        ["<Leader>db"] = { ":PBToggleBreakpoint<CR>", desc = "Toggle Breakpoint" },
        ["<Leader>dB"] = { ":PBClearAllBreakpoints<CR>", desc = "Clear All Breakpoints" },
        ["<Leader>dC"] = { ":PBSetConditionalBreakpoint<CR>", desc = "Set Conditional Breakpoint" },
        -- ["<Leader>dh"] = { function() require("dap.ui.widgets").preview() end, desc = "Debugger Hover" },
        -- Close all dap-ui hover windows
        -- ["<Leader>dx"] = { "", desc = "Close all dap-ui hovers" },

        -- NOTE: Spell Check
        -- ["zt"] = ":set spell!<CR>"

        -- NOTE: Buffer
        ["<Leader>bh"] = {
          "<cmd>lua require('astrocore.buffer').close_left()<CR>",
          desc = "Close all buffers to the left",
        },
        ["<Leader>bl"] = {
          "<cmd>lua require('astrocore.buffer').close_right()<CR>",
          desc = "Close all buffers to the right",
        },

        -- NOTE: Crates
        ["<Leader>R"] = { desc = "Crates" },
        ["<Leader>Ro"] = { "<cmd>lua require('crates').show_popup()<CR>", desc = "Show popup" },
        ["<Leader>Rr"] = { "<cmd>lua require('crates').reload()<CR>", desc = "Reload" },
        ["<Leader>Rv"] = { "<cmd>lua require('crates').show_versions_popup()<CR>", desc = "Show Versions" },
        ["<Leader>Rf"] = { "<cmd>lua require('crates').show_features_popup()<CR>", desc = "Show Features" },
        ["<Leader>Rd"] = {
          "<cmd>lua require('crates').show_dependencies_popup()<CR>",
          desc = "Show Dependencies Popup",
        },
        ["<Leader>Ru"] = { "<cmd>lua require('crates').update_crate()<CR>", desc = "Update Crate" },
        ["<Leader>Ra"] = { "<cmd>lua require('crates').update_all_crates()<CR>", desc = "Update All Crates" },
        ["<Leader>RU"] = { "<cmd>lua require('crates').upgrade_crate<CR>", desc = "Upgrade Crate" },
        ["<Leader>RA"] = { "<cmd>lua require('crates').upgrade_all_crates(true)<CR>", desc = "Upgrade All Crates" },
        ["<Leader>RH"] = { "<cmd>lua require('crates').open_homepage()<CR>", desc = "Open Homepage" },
        ["<Leader>RR"] = { "<cmd>lua require('crates').open_repository()<CR>", desc = "Open Repository" },
        ["<Leader>RD"] = { "<cmd>lua require('crates').open_documentation()<CR>", desc = "Open Documentation" },
        ["<Leader>RC"] = { "<cmd>lua require('crates').open_crates_io()<CR>", desc = "Open Crate.io" },

        ["gx"] = {
          function() require("astrocore").system_open(vim.fn.expand "<cfile>") end,
          desc = "Opens path/URI under cursor",
        },
      },

      -- PASSED: Visual Mode
      v = {
        ["<Leader>d"] = '"_d', -- register

        -- System clipboard (Neovim uses OSC52 automatically over SSH)
        ["<Leader>y"] = { '"+y', desc = "Yank to system clipboard" },

        -- Move line
        ["<A-j>"] = ":m '>+1<CR>gv-gv",
        ["<A-k>"] = ":m '<-2<CR>gv-gv",

        -- Better indenting
        ["<"] = "<gv",
        [">"] = ">gv",
      },

      -- PASSED: Terminal
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        -- ["jk"] = "<C-\\><C-n>",
        ["<C-space>"] = "<C-\\><C-n>",
      },
    },
  },
}
