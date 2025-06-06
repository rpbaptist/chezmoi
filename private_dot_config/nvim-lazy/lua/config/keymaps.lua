-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- This file is automatically loaded by lazyvim.config.init

vim.keymap.del("n", "<C-Up>")
vim.keymap.del("n", "<C-Down>")
vim.keymap.del("n", "<C-Left>")
vim.keymap.del("n", "<C-Right>")

vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-l>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

vim.keymap.del("n", "<leader>ft")

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

vim.keymap.set({ "n", "x", "v" }, "<leader>fD", function()
  local path = vim.fn.expand("%:.")
  vim.cmd(":! rm %")
  Snacks.bufdelete()
  vim.notify("Deleted " .. path)
end, { desc = "Delete file" })

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
