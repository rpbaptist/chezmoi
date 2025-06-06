return {
  "chrisgrieser/nvim-recorder",
  lazy = false,
  opts = {
    lessNotifications = true,
    mapping = {
      startStopRecording = "<leader>rr",
      switchSlot = "<leader>rs",
      editMacro = "<leader>re",
      deleteAllMacros = "<leader>rd",
      yankMacro = "<leader>ry",
    },
  },
  keys = {
    { "<leader>rr", desc = "Start/stop recording" },
    { "<leader>rs", desc = "Switch slot" },
    { "<leader>re", desc = "Edit macro" },
    { "<leader>rd", desc = "Delete all macros" },
    { "<leader>ry", desc = "Yank macro" },
  },
}
