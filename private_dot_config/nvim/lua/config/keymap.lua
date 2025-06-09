Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

local set = vim.keymap.set

set({ "n", "v" }, "<C-b>", "<C-u><C-u>")
set({ "n", "v" }, "<PageUp>", "<C-u><C-u>")

set("n", "<A-v>", "<C-v>")

-- True delete
set({ "n", "x", "v" }, "<leader>d", '"_d', { desc = "Delete without cut" })
-- set({ "n", "x", "v" }, "D", '"_D', { desc = "Delete until end of line" })
set({ "n", "x", "v" }, "c", '"_c', { desc = "Change without cut" })
set({ "n", "x", "v" }, "C", '"_C', { desc = "Change without cut" })
set({ "n", "x", "v" }, "x", '"_x', { desc = "Delete without cut" })
set({ "n", "x", "v" }, "X", '"_X', { desc = "Delete without cut" })
set("v", "p", "<s-p>", { remap = true })

-- Tab control
set("n", "]<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab", silent = true })
set("n", "[<Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab", silent = true })

set("i", "<C-CR>", "<C-o>o", { desc = "Open line below" })
set("i", "<S-CR>", "<C-o><S-o>", { desc = "Open line above" })

set("i", "<C-S-Up>", "<C-o><C-S-Up>")
set("i", "<C-S-Down>", "<C-o><C-S-Down>")

set({ "n", "i" }, "<C-BS>", "<C-o>db", { desc = "Delete backspace" })

set("i", "<Tab>", "<C-i>", { desc = "Indent" })
set("n", "i", function()
	if string.match(vim.api.nvim_get_current_line(), "%g") == nil then
		return "cc"
	else
		return "i"
	end
end, { expr = true })

set({ "n", "x", "i", "v" }, "<Home>", function()
	local column = vim.fn.col(".")
	vim.cmd("normal! ^")
	if column == vim.fn.col(".") then
		vim.cmd("normal! 0")
	end
end, { desc = "Move to beginning of line", remap = true })

set({ "n", "x", "v" }, "<leader>fP", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied " .. path .. " to clipboard")
end, { desc = "Copy absolute file path" })

set({ "n", "x", "v" }, "<leader>fp", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied " .. path .. " to clipboard")
end, { desc = "Copy relative file path" })

set({ "n", "x", "v" }, "<leader>fL", function()
	local path = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	vim.fn.setreg("+", path .. ":" .. line)
	vim.notify("Copied " .. path .. ":" .. line .. " to clipboard")
end, { desc = "Copy absolute file path with line" })

set({ "n", "x", "v" }, "<leader>fl", function()
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

set("n", "<leader>tt", ":lua TestCurrentFile()<CR>", { desc = "Test current file" })
set("n", "<leader>tl", ":lua TestCurrentLine()<CR>", { desc = "Test current line" })
set("n", "<leader>td", ":lua TestCurrentDirectory()<CR>", { desc = "Test current file directory" })
set("n", "<leader>tww", ":lua WatchCurrentFile()<CR>", { desc = "Watch current file" })
set("n", "<leader>tws", ":lua StopWatchingCurrentFile()<CR>", { desc = "Stop watching current file" })

-- better up/down
set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Move Lines
set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

set(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
set("i", ",", ",<c-g>u")
set("i", ".", ".<c-g>u")
set("i", ";", ";<c-g>u")

-- save file
set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--keywordprg
set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
set("v", "<", "<gv")
set("v", ">", ">gv")

-- commenting
set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- lazy
set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- location list
set("n", "<leader>xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

-- quickfix list
set("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })


set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- highlights under cursor
set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
set("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Terminal Mappings
-- set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
--
-- windows
set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
-- Snacks.toggle.zoom():set("<leader>wm"):set("<leader>uZ")
-- Snacks.toggle.zen():set("<leader>uz")
-- --
-- tabs
set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
