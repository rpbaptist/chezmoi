return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {},
    config = function()
      require("image").setup()
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
    end,
  },
  {
    "SmiteshP/nvim-navic",
    opts = {
      depth_limit_indicator = "…",
      separator = "  ",
      highlight = true,
      depth_limit = 0,
    },
  },
  {
    "Tummetott/reticle.nvim",
    event = "VeryLazy",
    opts = {
      always_highlight_number = true,
    },
  },
  {
    "tzachar/highlight-undo.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
