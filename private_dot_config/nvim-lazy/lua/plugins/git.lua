return {
  {
    "echasnovski/mini.diff",
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "+",
          change = "▪",
          delete = "",
        },
      },
    },
    keys = {
      {
        "<leader>gd",
        function()
          require("mini.diff").toggle_overlay()
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
  },
  {
    "SuperBo/fugit2.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    cmd = { "Fugit2", "Fugit2Diff", "Fugit2Graph" },
    opts = {
      libgit2_path = "libgit2.so.1.7",
      show_patch = true,
    },
    keys = {
      { "<leader>gs", "<cmd>Fugit2<cr>", desc = "Git status" },
    },
  },
}
