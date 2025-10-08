local function augroup(name)
	return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

local function resize_splits()
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("tabdo wincmd =")
	vim.cmd("tabnext " .. current_tab)
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		resize_splits()
	end,
})

-- resize splits when terminal is opened (ergoterm support)
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
	group = augroup("terminal_resize_splits"),
	callback = function()
		if vim.bo.buftype == "terminal" then
			-- Only resize if not a horizontal split (below layout)
			local win_height = vim.api.nvim_win_get_height(0)
			local total_height = vim.o.lines
			-- Skip resize if this appears to be a horizontal split (below layout)
			-- Horizontal terminals typically have small height relative to total height
			if win_height / total_height > 0.3 then -- Only resize if height is more than 30% of screen
				resize_splits()
			end
		end
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Autosave buffer
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
	callback = function()
		local buf = vim.api.nvim_get_current_buf()

		vim.api.nvim_buf_call(buf, function()
			vim.cmd("silent! write")
		end)
	end,
	pattern = "*",
})

-- remove search highlight when moving the cursor
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end,
})

-- Auto enter insert mode when focusing terminal buffers
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	group = augroup("terminal_insert_mode"),
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
	end,
})

-- Add lazy lock file after update
-- TODO: After migrating to vim.pack, use `PackChanged` event.
vim.api.nvim_create_autocmd("User", {
	pattern = { "LazyUpdate", "LazySync", "LazyClean" },
	group = augroup("chezmoi_update_lock"),
	callback = function()
		vim.schedule(function()
			vim.fn.system("chezmoi add " .. vim.fn.stdpath("config") .. "/lazy-lock.json")
		end)
	end,
})
