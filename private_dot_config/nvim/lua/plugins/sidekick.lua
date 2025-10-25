return {
	"folke/sidekick.nvim",
	opts = {
    nes = {
      enabled = false,
    },
		keys = {
			buffers = { "<c-b>", "buffers", mode = "nt", desc = "open buffer picker" },
			files = { "<c-f>", "files", mode = "nt", desc = "open file picker" },
			hide_n = { "q", "hide", mode = "n", desc = "hide the terminal window" },
			hide_ctrl_q = { "<c-q>", "hide", mode = "n", desc = "hide the terminal window" },
			hide_ctrl_dot = { "<c-.>", "hide", mode = "nt", desc = "hide the terminal window" },
			prompt = { "<c-p>", "prompt", mode = "t", desc = "insert prompt or context" },
			stopinsert = { "<c-q>", "stopinsert", mode = "t", desc = "enter normal mode" },
			-- Navigate windows in terminal mode. Only active when:
			-- * layout is not "float"
			-- * there is another window in the direction
			-- With the default layout of "right", only `<c-h>` will be mapped
			nav_left = { "<c-a-n>", "nav_left", expr = true, desc = "navigate to the left window" },
			nav_down = { "<c-a-e>", "nav_down", expr = true, desc = "navigate to the below window" },
			nav_up = { "<c-a-u>", "nav_up", expr = true, desc = "navigate to the above window" },
			nav_right = { "<c-a-i>", "nav_right", expr = true, desc = "navigate to the right window" },
		},
	},
	keys = {
		-- {
		-- 	"<tab>",
		-- 	function()
		-- 		-- if there is a next edit, jump to it, otherwise apply it if any
		-- 		if not require("sidekick").nes_jump_or_apply() then
		-- 			return "<Tab>" -- fallback to normal tab
		-- 		end
		-- 	end,
		-- 	mode = { "i", "n" },
		-- 	expr = true,
		-- 	desc = "Goto/Apply Next Edit Suggestion",
		-- },
		{
			"<c-.>",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle",
			mode = { "n", "t", "i", "x" },
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle({ name = "claude", focus = true })
			end,
			desc = "Sidekick Toggle",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
	},
}
