return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    opts = {},
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({
            transient = true,
            prefills = {
              paths = vim.fn.expand("%"),
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        desc = "Search and replace",
      },
    },
  },
}
