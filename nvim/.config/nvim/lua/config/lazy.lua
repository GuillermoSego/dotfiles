-- ~/.config/nvim/lua/config/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- Última versión estable
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Tema para hacer el código más legible y atractivo
    { "morhetz/gruvbox" },

    -- Barra de estado
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "gruvbox",
                },
            })
        end,
    },

    -- Explorador de archivos
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                renderer = {
                    icons = {
                        webdev_colors = true,
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                        glyphs = {
                            default = "",
                            symlink = "",
                            folder = {
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                            },
                        },
                    },
                },
                view = {
                    width = 30,
                    side = "left",
                },
                filters = {
                    dotfiles = false,
                },
            })
        end,
    },

    -- Git extension
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- Soporte de íconos
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end,
    },

    -- Lineas para identación
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = { char = "│" },
        scope = { enabled = true },
      }
    },
    
    -- Identación o formato automático
    {
        "stevearc/conform.nvim",
        opts = {
            format_on_save = {
                timeout_ms = 1000,
                lsp_fallback = true,
            },
            formatters_by_ft = {
                python = { "black" },
                lua = { "stylua" },
                javascript = { "prettier" },
            },
        },
    },


    -- Mostrar la función que trabajamos
    {
      "nvim-treesitter/nvim-treesitter-context",
      config = function()
        require("treesitter-context").setup({
          max_lines = 1,
          multiline_threshold = 2,
          trim_scope = "outer",
        })
      end,
    },


    -- Errores
    {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}
    },



    -- Syntax Highlighting
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- Autocompletado
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }),
        })
      end,
    },


    -- LSP Configuración
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp").setup()
        end,
    },

    -- Mason
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright" }, 
            })
        end,
    },


    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- Autocompletado paréntesis/comillas ...
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local npairs = require("nvim-autopairs")
        npairs.setup({})

        -- Integración con nvim-cmp
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },

    -- Comentarios
    {
      "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup()
      end
    },

    -- Copilot
    {
        "github/copilot.vim",
        lazy = false,  -- Cargar al inicio (opcional)
    }

    


})

-- Configuración del tema
vim.cmd("colorscheme gruvbox")

-- Configuración de nvim-cmp para autocompletado
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }),
})

-- Asignar una tecla para abrir el explorador de archivos
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Configuración del LSP (servidores de lenguaje)
local lspconfig = require("lspconfig")
lspconfig.pyright.setup{}

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Gitsigns config extendida
require("gitsigns").setup({
    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
    },
    current_line_blame = true,
    signcolumn = true,
    numhl      = false,
    linehl     = false,
    watch_gitdir = {
        interval = 1000,
    },
})

local builtin = require("telescope.builtin")

-- Buscar archivos del proyecto
vim.keymap.set("n", "<C-p>", builtin.find_files, { noremap = true, silent = true })

-- Buscar texto dentro de archivos
vim.keymap.set("n", "<C-f>", builtin.live_grep, { noremap = true, silent = true })

-- Ver buffers abiertos
vim.keymap.set("n", "<leader>b", builtin.buffers, { noremap = true, silent = true })

-- Ver historial de comandos
vim.keymap.set("n", "<leader>h", builtin.command_history, { noremap = true, silent = true })

-- Mapa de errores
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hb", "<cmd>Gitsigns blame_line<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hh", "<cmd>Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

