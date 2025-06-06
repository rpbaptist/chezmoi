return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = true },
      copilot_node_command = vim.fn.expand("$HOME") .. "/.local/share/mise/installs/node/latest/bin/node",
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "saghen/blink.cmp",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = "  Copilot",
            user = "  Prompt",
          },
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
            ["fetch"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
            ["file"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
            ["help"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
            ["symbols"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
          },
          keymaps = {
            completion = {
              modes = {
                i = "<C-.>",
              },
            },
            send = {
              modes = {
                n = "C-s",
              },
            },
          },
        },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
      display = {
        action_palette = {
          provider = "fzf_lua",
        },
        chat = {
          window = {
            width = 0.28,
          },
          show_settings = true,
          start_in_insert_mode = true,
        },
        diff = {
          provider = "mini_diff",
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- default = "gpt-4o-2024-05-13",
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd:cat $HOME/.local/anthropic",
            },
            schema = {
              model = {
                default = "claude-3-7-sonnet-20250219",
              },
            },
          })
        end,
      },
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion actions", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = "CodeCompanion chat", mode = { "n", "v" } },
      {
        "<leader>ai",
        function()
          require("codecompanion").prompt("buffer")
        end,
        desc = "CodeCompanion chat inline",
        mode = { "n", "v" },
      },
      { "<leader>at", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion chat toggle", mode = { "n", "v" } },
      { "<leader>ae", "<cmd>CodeCompanionChat Add<CR>", desc = "CodeCompanion chat add", mode = { "n", "v" } },
    },
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
