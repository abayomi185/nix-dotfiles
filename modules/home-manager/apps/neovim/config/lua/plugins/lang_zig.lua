return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "lawrence-laz/neotest-zig", version = "^1" },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-zig")
    end,
  },
}
