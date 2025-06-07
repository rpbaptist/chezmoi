Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

vim.keymap.set({ "n", "v" }, "<C-b>", "<C-u><C-u>")
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-u><C-u>")

vim.keymap.set("n", "<A-v>", "<C-v>")

-- True delete
vim.keymap.set({ "n", "x", "v" }, "<leader>d", '"_d', { desc = "Delete without cut" })
-- vim.keymap.set({ "n", "x", "v" }, "D", '"_D', { desc = "Delete until end of line" })
vim.keymap.set({ "n", "x", "v" }, "c", '"_c', { desc = "Change without cut" })
vim.keymap.set({ "n", "x", "v" }, "C", '"_C', { desc = "Change without cut" })
vim.keymap.set({ "n", "x", "v" }, "x", '"_x', { desc = "Delete without cut" })
vim.keymap.set({ "n", "x", "v" }, "X", '"_X', { desc = "Delete without cut" })
vim.keymap.set("v", "p", "<s-p>", { remap = true })

-- Tab control
vim.keymap.set("n", "]<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab", silent = true })
vim.keymap.set("n", "[<Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab", silent = true })

vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Open line below" })
vim.keymap.set("i", "<S-CR>", "<C-o><S-o>", { desc = "Open line above" })

vim.keymap.set("i", "<C-S-Up>", "<C-o><C-S-Up>")
vim.keymap.set("i", "<C-S-Down>", "<C-o><C-S-Down>")

vim.keymap.set({ "n", "i" }, "<C-BS>", "<C-o>db", { desc = "Delete backspace" })

vim.keymap.set("i", "<Tab>", "<C-i>", { desc = "Indent" })
vim.keymap.set("n", "i", function()
	if string.match(vim.api.nvim_get_current_line(), "%g") == nil then
		return "cc"
	else
		return "i"
	end
end, { expr = true })

vim.keymap.set({ "n", "x", "i", "v" }, "<Home>", function()
	local column = vim.fn.col(".")
	vim.cmd("normal! ^")
	if column == vim.fn.col(".") then
		vim.cmd("normal! 0")
	end
end, { desc = "Move to beginning of line", remap = true })

vim.keymap.set({ "n", "x", "v" }, "<leader>fP", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied " .. path .. " to clipboard")
end, { desc = "Copy absolute file path" })

vim.keymap.set({ "n", "x", "v" }, "<leader>fp", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied " .. path .. " to clipboard")
end, { desc = "Copy relative file path" })

vim.keymap.set({ "n", "x", "v" }, "<leader>fL", function()
	local path = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	vim.fn.setreg("+", path .. ":" .. line)
	vim.notify("Copied " .. path .. ":" .. line .. " to clipboard")
end, { desc = "Copy absolute file path with line" })

vim.keymap.set({ "n", "x", "v" }, "<leader>fl", function()
	local path = vim.fn.expand("%:.")
	local line = vim.fn.line(".")
	vim.fn.setreg("+", path .. ":" .. line)
	vim.notify("Copied " .. path .. ":" .. line .. " to clipboard")
end, { desc = "Copy relative file path with line" })

function TestCurrentFile()
	local current_file = vim.fn.expand("%:p")
	local cmd = 'IexTests.test("' .. current_file .. '")'
	Snacks.terminal.get(cmd)
end

function TestCurrentLine()
	local current_file = vim.fn.expand("%:p")
	local current_line = vim.fn.line(".")
	local cmd = 'IexTests.test("' .. current_file .. '", ' .. current_line .. ")"
	Snacks.terminal.get(cmd)
end

function TestCurrentDirectory()
	local file_dir = vim.fn.expand("%:p:h")
	local cmd = 'IexTests.test("' .. file_dir .. '")'
	Snacks.terminal.get(cmd)
end

function WatchCurrentFile()
	local current_file = vim.fn.expand("%:p")
	local cmd = 'IexTests.test_watch("' .. current_file .. '")'
	Snacks.terminal.get(cmd)
end

function StopWatchingCurrentFile()
	Snacks.terminal.get("IexTests.stop_watch()")
end

vim.keymap.set("n", "<leader>tt", ":lua TestCurrentFile()<CR>", { desc = "Test current file" })
vim.keymap.set("n", "<leader>tl", ":lua TestCurrentLine()<CR>", { desc = "Test current line" })
vim.keymap.set("n", "<leader>td", ":lua TestCurrentDirectory()<CR>", { desc = "Test current file directory" })
vim.keymap.set("n", "<leader>tww", ":lua WatchCurrentFile()<CR>", { desc = "Watch current file" })
vim.keymap.set("n", "<leader>tws", ":lua StopWatchingCurrentFile()<CR>", { desc = "Stop watching current file" })

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

vim.keymap.set(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--keywordprg
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- commenting
vim.keymap.set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- location list
vim.keymap.set("n", "<leader>xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

-- quickfix list
vim.keymap.set("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
-- local diagnostic_goto = function(next, severity)
-- 	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
-- 	severity = severity and vim.diagnostic.severity[severity] or nil
-- 	return function()
-- 		go({ severity = severity })
-- 	end
-- end
-- vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
-- vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
-- vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
-- vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
-- vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
-- vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
-- vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
-- vim.keymap.set("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })

-- highlights under cursor
vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
vim.keymap.set("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Terminal Mappings
-- vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
--
-- windows
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
-- Snacks.toggle.zoom():vim.keymap.set("<leader>wm"):vim.keymap.set("<leader>uZ")
-- Snacks.toggle.zen():vim.keymap.set("<leader>uz")
-- --
-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
