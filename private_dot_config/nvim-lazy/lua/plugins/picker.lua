return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      "fzf-native",
      defaults = {
        file_ignore_patterns = {
          -- "lib/eor/*",
          -- "test/eor/*",
          -- "**/eor/*",
          "deps/*",
          "_build/*",
          ".elixir_ls/*",
        },
        grep = {
          rg_glob = true,
        },
        oldfiles = {
          include_current_session = true,
        },
        -- no_header = true,
      },
    },
    keys = {
      { "<leader>gc", false },
      { "<leader>gs", false },
      { "<leader>sg", false },
      { "<leader>sg", "<cmd>FzfLua live_grep_glob<cr>", desc = "grep with glob (root dir)" },
      { "<leader>gb", "<cmd>FzfLua git_bcommits<cr>", desc = "Git blame" },
      { "<leader>gl", "<cmd>FzfLua git_commits<cr>", desc = "Git log" },
      { "<leader>go", "<cmd>FzfLua git_branches<cr>", desc = "Git checkout" },
      { "<leader>gf", "<cmd>FzfLua git_status<cr>", desc = "Git files" },
      { "<leader>bl", "<cmd>FzfLua buffers<cr>", desc = "List buffers" },
      { "<leader>D", "<cmd>FzfLua spell_suggest<cr>", desc = "Spell suggestions" },
      { "<leader><Tab>l", "<cmd>FzfLua tabs<cr>", desc = "List tabs" },
      {
        "<leader>sG",
        function()
          require("fzf-lua").live_grep({ cwd = vim.fn.expand("%:h") })
        end,
        desc = "Grep current dir",
      },
    },
  },
}
