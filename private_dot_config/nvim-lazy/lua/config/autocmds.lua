-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

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

