return {
  "folke/snacks.nvim",
  cmd = "Snacks",
  opts = {
    notifier = {
      timeout = 5000,
      style = "compact",
      styles = {
        notification = {
          wo = {
            winblend = 5,
            wrap = true,
            conceallevel = 2,
            colorcolumn = "",
          },
        },
      },
    },
    indent = {
      indent = {
        hl = "GruvboxBg1",
      },
      scope = {
        only_current = true,
        hl = "GruvboxBg3",
      },
    },
    scratch = {
      styles = {
        height = 50,
      },
    },
    scroll = {
      animate = {
        duration = { step = 15, total = 160 },
      },
    },
     dashboard = {
      enabled = true,
      preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "g", desc = "Git status", action = ":Fugit2" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>nh",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification history",
    },
    {
      "<leader>gB",
      mode = { "n", "v" },
      function()
        Snacks.gitbrowse.open()
      end,
      desc = "Open file in browser",
    },
    {
      "<leader>.c",
      function()
        Snacks.scratch()
      end,
      desc = "match current code",
    },
    {
      "<leader>.m",
      function()
        Snacks.scratch({ ft = "markdown" })
      end,
      desc = "markdown",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
  },
}
