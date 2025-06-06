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
}
