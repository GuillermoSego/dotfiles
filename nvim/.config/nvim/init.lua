-- Agregar node/npm al PATH para que nvim-treesitter pueda compilar parsers
vim.env.PATH = vim.env.HOME .. "/.nvm/versions/node/v24.15.0/bin:" .. vim.env.PATH

-- Color verdadero (necesario para que Cyberdream se vea correctamente)
vim.opt.termguicolors = true

-- Número de línea y estilo
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.updatetime = 300
vim.g.mapleader = " "

-- Cargar lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

-- Folding con Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Configuración keymaps
vim.keymap.set("n", "<leader>ns", ":nohlsearch<CR>", { noremap = true, silent = true })

require("config.lazy")
