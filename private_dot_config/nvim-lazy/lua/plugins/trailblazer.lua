return {
  "LeonHeidelbach/trailblazer.nvim",
  lazy = true,
  cmd = {
    "TrailBlazerNewTrailMark",
    "TrailBlazerTrackBack",
    "TrailBlazerPeekMovePreviousUp",
    "TrailBlazerPeekMoveNextDown",
    "TrailBlazerMoveToNearest",
    "TrailBlazerMoveToTrailMarkCursor",
    "TrailBlazerDeleteAllTrailMarks",
    "TrailBlazerPasteAtLastTrailMark",
    "TrailBlazerPasteAtAllTrailMarks",
    "TrailBlazerTrailMarkSelectMode",
    "TrailBlazerToggleTrailMarkList",
    "TrailBlazerOpenTrailMarkList",
    "TrailBlazerCloseTrailMarkList",
    "TrailBlazerSwitchTrailMarkStack",
    "TrailBlazerAddTrailMarkStack",
    "TrailBlazerDeleteTrailMarkStacks",
    "TrailBlazerDeleteAllTrailMarkStacks",
    "TrailBlazerSwitchNextTrailMarkStack",
    "TrailBlazerSwitchPreviousTrailMarkStack",
    "TrailBlazerSetTrailMarkStackSortMode",
    "TrailBlazerSaveSession",
    "TrailBlazerLoadSession",
    "TrailBlazerDeleteSession",
  },
  opts = {
    trail_options = {
      -- mark_symbol = "•", --  will only be used if trail_mark_symbol_line_indicators_enabled = true
      newest_mark_symbol = "󰃁", -- disable this mark symbol by setting its value to ""
      cursor_mark_symbol = "󰃀", -- disable this mark symbol by setting its value to ""
      next_mark_symbol = "󰃅", -- disable this mark symbol by setting its value to ""
      previous_mark_symbol = "󰧌",
    },
    force_mappings = {
      nv = {
        motions = {
          new_trail_mark = "",
          track_back = "",
          peek_move_next_down = "",
          peek_move_previous_up = "",
          move_to_nearest = "",
          toggle_trail_mark_list = "",
        },
        actions = {
          delete_all_trail_marks = "",
          paste_at_last_trail_mark = "",
          paste_at_all_trail_marks = "",
          set_trail_mark_select_mode = "",
          switch_to_next_trail_mark_stack = "",
          switch_to_previous_trail_mark_stack = "",
          set_trail_mark_stack_sort_mode = "",
        },
      },
    },
  },
  keys = {
    { "<leader>mm", "<cmd>TrailBlazerNewTrailMark<cr>", desc = "New trail mark" },
    { "<leader>mb", "<cmd>TrailBlazerTrackBack<cr>", desc = "Track back" },
    { "<leader>me", "<cmd>TrailBlazerPeekMovePreviousDown<cr>", desc = "Peek move previous down" },
    { "<leader>mu", "<cmd>TrailBlazerPeekMovePreviousUp<cr>", desc = "Peek move previous up" },
    { "<leader>mn", "<cmd>TrailBlazerPeekMoveToNearest<cr>", desc = "Peek move to nearest" },
    { "<leader>ml", "<cmd>TrailBlazerToggleTrailMarkList<cr>", desc = "Toggle trail mark list" },
    { "<leader>mx", "<cmd>TrailBlazerDeleteAllTrailMarkStacks<cr>", desc = "Delete all trail mark stacks" },
    { "<leader>mp", "<cmd>TrailBlazerPasteAtLastTrailMark<cr>", desc = "Paste at last trail mark" },
    { "<leader>mP", "<cmd>TrailBlazerPasteAtAllTrailMarks<cr>", desc = "Paste at all trail marks" },
    { "<A-,>", "<cmd>TrailBlazerSwitchNextTrailMarkStack<cr>", desc = "Switch to next trail mark stack" },
    { "<A-.>", "<cmd>TrailBlazerSwitchPreviousTrailMarkStack<cr>", desc = "Switch to previous trail mark stack" },
    { "<leader>ms", "<cmd>TrailBlazerSetTrailMarkStackSortMode<cr>", desc = "Set trail mark stack sort mode" },
  },
}
