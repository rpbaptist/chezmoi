return {
	"nvim-lualine/lualine.nvim",
	depencencies = {
		"chrisgrieser/nvim-recorder",
		"echasnovski/mini.diff",
		"SmiteshP/nvim-navic",
	},
	opts = function()
		local recording_status = function()
			local ok, recorder = pcall(require, "recorder")
			return ok and recorder.recordingStatus()
		end

		local recorder_display_slots = function()
			local ok, recorder = pcall(require, "recorder")
			return ok and recorder.displaySlots()
		end
		local icons = vim.g.custom_icons.modified
		return {
			options = {
				disabled_filetypes = {
					statusline = { "snacks_dashboard" },
					winbar = { "snacks_dashboard" },
				},
			},
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_x = {
					"searchcount",
					"selectioncount",
					{
						"diff",
						symbols = icons,
						source = function()
							local minidiff_data = require("mini.diff").get_buf_data(0)

							if minidiff_data and minidiff_data["overlay"] then
								local summary = vim.b.minidiff_summary

								return summary
									and {
										added = summary.add,
										modified = summary.change,
										removed = summary.delete,
									}
							end
						end,
					},
					{ recorder_display_slots },
					{ recording_status },
				},
				lualine_y = {
					"progress",
				},
				lualine_z = { "location" },
			},
			winbar = {
				lualine_c = {
					{
						"filetype",
						icon_only = true,
						separator = "",
						icon = { align = "left" },
						color = { bg = "#32302f" },
						padding = { left = 2, right = 1 },
					},
					{
						"filename",
						color = { fg = "#ebdbb2", bg = "#32302f" },
						separator = "",
            symbols = icons,
					},
					"navic",
				},
			},
			inactive_winbar = {
				lualine_c = {
					{
						"filetype",
						icon_only = true,
						separator = "",
						icon = { align = "left" },
						color = { bg = "#32302f" },
						padding = { left = 2, right = 1 },
					},
					{
						"filename",
						color = { fg = "#bdae93", bg = "#32302f" },
						separator = "",
						symbols = icons,
					},
				},
			},
		}
	end,
}
