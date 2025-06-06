return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- local Keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- vim.list_extend(Keys, {
      --   -- { "gd", "<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
      --   -- { "gr", false },
      --   -- { "gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
      --   -- { "gy", "<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
      -- })
      -- vim.tbl_deep_extend("error", opts.servers.elixirls, {
      --   settings = {
      --     elixirLS = {
      --       mixEnv = "dev",
      --       mixTarget = "dev",
      --     },
      --   },
      -- })
    end,
  },
}
