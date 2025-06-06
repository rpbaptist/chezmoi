-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.env.PATH = vim.fn.execute("echo $PATH"):gsub("%s+", "")

vim.opt.relativenumber = false
vim.opt.clipboard = "unnamedplus"
vim.opt.textwidth = 120
vim.opt.inccommand = "nosplit"
vim.opt.termguicolors = true
vim.opt.swapfile = false

vim.g.lazygit_config = false

vim.g.kitty_navigator_no_mappings = 1
vim.g.kitty_navigator_password = "nvimwindows"

vim.g.maplocalleader = ","
vim.g.lazyvim_blink_main = true

vim.o.background = "dark"
vim.opt.laststatus = 3
