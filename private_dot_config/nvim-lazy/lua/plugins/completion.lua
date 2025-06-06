return {
  {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<Esc"] = { "hide", "fallback" },
      },
      sources = {
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
          copilot = {
            score_offset = -100,
          },
        },
      },
      completion = {
        keyword = {
          range = "full",
        },
        list = {
          selection = {
            preselect = function(_ctx)
              return not require("blink.cmp").snippet_active({ direction = 1 })
            end,
          },
        },
      },
    },
  },
}
