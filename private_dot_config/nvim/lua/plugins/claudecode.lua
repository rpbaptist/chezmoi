return {
	"coder/claudecode.nvim",
	dependencies = {
		"waiting-for-dev/ergoterm.nvim",
	},
	event = "VeryLazy",
	opts = {
		terminal = {
			provider = require("utils.claude-ergoterm"),
		},
    diff_opts = {
      keep_terminal_focus = true, 
    },
	},
	keys = {
		{ "<leader>a", group = "AI" },
		{ "<leader>at", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>aR", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "snacks_picker_list" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ar", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject diff" },
	},
}
