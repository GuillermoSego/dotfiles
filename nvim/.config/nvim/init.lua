-- Número de línea y estilo
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.g.mapleader = " "

-- Cargar lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configuración keymaps
vim.keymap.set("n", "<leader>ns", ":nohlsearch<CR>", { noremap = true, silent = true })

require("config.lazy")

