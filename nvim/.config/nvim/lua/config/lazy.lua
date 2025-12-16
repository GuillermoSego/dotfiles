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
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          integrations = {
            nvimtree = true,
            lualine = true,
            treesitter = true,
            cmp = true,
            telescope = true,
          },
        })
        vim.cmd.colorscheme("catppuccin-macchiato") -- Puedes usar latte, frappe, macchiato, mocha
      end,
    },


    -- Barra de estado
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "SmiteshP/nvim-navic", 
        },
        config = function()
            local navic = require("nvim-navic")

            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "catppuccin",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        { "filename" },
                        {
                            function()
                                return navic.get_location()
                            end,
                            cond = function()
                                return navic.is_available()
                            end,
                        },
                    },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
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
                    git_ignored = false,
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

    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
          vim.g.VM_default_mappings = 0
          vim.g.VM_maps = {
            ["Find Under"]        = "<leader>mc",   -- seleccionar palabra bajo el cursor y añadir siguiente
            ["Find Subword Under"]= "<leader>mc",
            ["Select All"]        = "<leader>ma",   -- seleccionar todas las ocurrencias
            ["Add Cursor Down"]   = "<C-j>",   -- añade cursor abajo
            ["Add Cursor Up"]     = "<C-k>",   -- añade cursor arriba
            ["Skip Region"]       = "<C-x>",   -- saltar la ocurrencia actual
            ["Remove Region"]     = "<C-p>",   -- quitar la ocurrencia actual
            ["Exit"]              = "<Esc>",   -- salir del modo multi
          }
          -- Opcional: que resalte las coincidencias
          vim.g.VM_highlight_matches = "underline"
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
      config = function() require("mason").setup() end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      version = "1.29.1",
      dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
      },
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "pyright" },
          automatic_installation = true,
          handlers = {},
        })
      end,
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
                -- 👇 aquí añadimos JSON
                json = { "jq_min" },
            },
            -- definimos el formatter jq_min
            formatters = {
                jq_min = {
                    command = "jq",
                    args = { "-c", "." }, -- -c = compact (minify)
                    stdin = true,
                },
            },
        },

        -- keymaps para usar conform cómodamente
        keys = {
            {
                "<leader>jf",
                function()
                    require("conform").format({
                        async = false,
                        lsp_fallback = true,
                    })
                end,
                mode = { "n", "v" },
                desc = "Formatear buffer con Conform",
            },
            {
                "<leader>jm",
                function()
                    -- fuerza usar jq_min (minificar JSON)
                    require("conform").format({
                        async = false,
                        lsp_fallback = false,
                        formatters = { "jq_min" },
                    })
                end,
                mode = { "n", "v" },
                desc = "Minificar JSON con jq",
            },
        },
    },

      -- Black (formatter) via none-ls
      {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
          local null_ls = require("null-ls")
          null_ls.setup({
            on_init = function(client, _)
                client.offset_encoding = "utf-8"
            end,
            sources = {
              null_ls.builtins.formatting.black.with({
                command = "uvx", -- usa uvx black
                args = { "black", "--stdin-filename", "$FILENAME", "-" },
                filetypes = { "python" },
              }),
            },
          })

          -- formatea con black automáticamente al guardar .py
          local aug = vim.api.nvim_create_augroup("FormatPythonWithBlack", { clear = true })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = aug,
            pattern = "*.py",
            callback = function()
              vim.lsp.buf.format({
                filter = function(c) return c.name == "null-ls" end,
                timeout_ms = 5000,
              })
            end,
          })
        end,
      },

    -- Errores
    {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}
    },


    -- Syntax Highlighting, function jumps, ident blocks
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        ensure_installed = { "python", "lua", "bash", "json", "yaml", "markdown" },
        highlight = { enable = true },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      config = function()
        require("nvim-treesitter.configs").setup({
          textobjects = {
            -- Selecciones (afuera/adentro de función, clase, bloque)
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ab"] = "@block.outer",   -- if/for/while/with/try/except/def/class, etc.
                ["ib"] = "@block.inner",
              },
            },
            -- Movimientos (inicio/fin de función, clase, bloque)
            move = {
              enable = true,
              set_jumps = true,
              goto_next_start = {
                ["]m"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]b"] = "@block.outer",   -- << salto al siguiente bloque de indentación
              },
              goto_next_end = {
                ["]M"] = "@function.outer",
                ["]C"] = "@class.outer",
                ["]B"] = "@block.outer",
              },
              goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[b"] = "@block.outer",   -- << bloque anterior
              },
              goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[C"] = "@class.outer",
                ["[B"] = "@block.outer",
              },
            },
          },
        })
      end,
    },

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
          performance = {
            debounce = 60,          -- ms entre tecleo y nueva petición
            throttle = 30,
            fetching_timeout = 100, -- corta backends lentos
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

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
              pickers = {
                buffers = {
                  sort_lastused = true,
                  mappings = {
                    i = {
                      ["<c-d>"] = "delete_buffer", -- en modo insert
                    },
                    n = {
                      ["d"] = "delete_buffer",     -- en modo normal
                    },
                  },
                },
              },
            })
        end
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



})

-- Asignar una tecla para abrir el explorador de archivos
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true })

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
