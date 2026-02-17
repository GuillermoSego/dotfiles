-- ~/.config/nvim/lua/config/lazy.lua
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

require("lazy").setup({
    -- ============================================
    -- UI Y TEMA
    -- ============================================

    -- Tema Catppuccin
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                integrations = {
                    neotree = true,
                    lualine = true,
                    treesitter = true,
                    cmp = true,
                    telescope = true,
                    gitsigns = true,
                    dap = true,
                    dap_ui = true,
                    aerial = true,
                    noice = true,
                    notify = true,
                },
            })
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },

    -- Barra de estado (lualine)
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
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
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

    -- Explorador de archivos (Neo-tree - más moderno)
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = false,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,

                -- Posición por defecto
                default_component_configs = {
                    indent = {
                        indent_size = 2,
                        padding = 1,
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        highlight = "NeoTreeIndentMarker",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "",
                        default = "",
                    },
                    modified = {
                        symbol = "[+]",
                        highlight = "NeoTreeModified",
                    },
                    name = {
                        trailing_slash = false,
                        use_git_status_colors = true,
                        highlight = "NeoTreeFileName",
                    },
                    git_status = {
                        symbols = {
                            added     = "✚",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "󰁕",
                            untracked = "",
                            ignored   = "",
                            unstaged  = "󰄱",
                            staged    = "",
                            conflict  = "",
                        }
                    },
                },

                window = {
                    position = "left",
                    width = 35,
                    mapping_options = {
                        noremap = true,
                        nowait = true,
                    },
                    mappings = {
                        ["<space>"] = {
                            "toggle_node",
                            nowait = false,
                        },
                        ["<2-LeftMouse>"] = "open",
                        ["<cr>"] = "open",
                        ["<esc>"] = "cancel",
                        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
                        ["l"] = "focus_preview",
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        ["t"] = "open_tabnew",
                        ["w"] = "open_with_window_picker",
                        ["C"] = "close_node",
                        ["z"] = "close_all_nodes",
                        ["a"] = {
                            "add",
                            config = {
                                show_path = "none"
                            }
                        },
                        ["A"] = "add_directory",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy",
                        ["m"] = "move",
                        ["q"] = "close_window",
                        ["R"] = "refresh",
                        ["?"] = "show_help",
                        ["<"] = "prev_source",
                        [">"] = "next_source",
                        ["i"] = "show_file_details",
                    },
                },

                filesystem = {
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        hide_hidden = true,
                        hide_by_name = {
                            "node_modules"
                        },
                        hide_by_pattern = {
                            "*.pyc",
                        },
                        always_show = {
                            ".gitignore",
                        },
                        never_show = {
                            ".DS_Store",
                            "thumbs.db"
                        },
                    },
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = false,
                    hijack_netrw_behavior = "open_default",
                    use_libuv_file_watcher = false,
                    window = {
                        mappings = {
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["H"] = "toggle_hidden",
                            ["/"] = "fuzzy_finder",
                            ["D"] = "fuzzy_finder_directory",
                            ["#"] = "fuzzy_sorter",
                            ["f"] = "filter_on_submit",
                            ["<c-x>"] = "clear_filter",
                            ["[g"] = "prev_git_modified",
                            ["]g"] = "next_git_modified",
                            ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["og"] = { "order_by_git_status", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        },
                        fuzzy_finder_mappings = {
                            ["<down>"] = "move_cursor_down",
                            ["<C-n>"] = "move_cursor_down",
                            ["<up>"] = "move_cursor_up",
                            ["<C-p>"] = "move_cursor_up",
                        },
                    },
                },

                buffers = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = true,
                    show_unloaded = true,
                    window = {
                        mappings = {
                            ["bd"] = "buffer_delete",
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        }
                    },
                },

                git_status = {
                    window = {
                        position = "float",
                        mappings = {
                            ["A"]  = "git_add_all",
                            ["gu"] = "git_unstage_file",
                            ["ga"] = "git_add_file",
                            ["gr"] = "git_revert_file",
                            ["gc"] = "git_commit",
                            ["gp"] = "git_push",
                            ["gg"] = "git_commit_and_push",
                            ["o"]  = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        }
                    }
                },
            })

            -- ============================================
            -- KEYMAPS
            -- ============================================

            -- Toggle lateral (normal)
            vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {
                desc = "Toggle Neo-tree",
                noremap = true,
                silent = true
            })

            -- Toggle FLOTANTE (COMO TU JEFE)
            vim.keymap.set("n", "<leader>e", ":Neotree float<CR>", {
                desc = "Neo-tree Float",
                noremap = true,
                silent = true
            })

            -- Focus en el archivo actual
            vim.keymap.set("n", "<leader>nf", ":Neotree reveal<CR>", {
                desc = "Neo-tree Reveal current file",
                noremap = true,
                silent = true
            })

            -- Git status
            vim.keymap.set("n", "<leader>ng", ":Neotree git_status<CR>", {
                desc = "Neo-tree Git status",
                noremap = true,
                silent = true
            })

            -- Buffers
            vim.keymap.set("n", "<leader>nb", ":Neotree buffers<CR>", {
                desc = "Neo-tree Buffers",
                noremap = true,
                silent = true
            })
        end,
    },

    -- Iconos
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end,
    },

    -- Líneas de indentación
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true },
        },
    },

    -- ============================================
    -- GIT
    -- ============================================

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
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
                numhl = false,
                linehl = false,
                watch_gitdir = {
                    interval = 1000,
                },
            })

            -- Keymaps de Git
            local gs = require("gitsigns")

            -- Navegación entre hunks
            vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next git hunk" })
            vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Previous git hunk" })

            -- Acciones de Git
            vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
            vim.keymap.set("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
            vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
            vim.keymap.set("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
            vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
            vim.keymap.set("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
            vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
        end,
    },

    -- ============================================
    -- EDICIÓN Y NAVEGACIÓN
    -- ============================================

    -- Multi-cursor
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            vim.g.VM_default_mappings = 0
            vim.g.VM_maps = {
                ["Find Under"]         = "<leader>mc",
                ["Find Subword Under"] = "<leader>mc",
                ["Select All"]         = "<leader>ma",
                ["Add Cursor Down"]    = "<C-j>",
                ["Add Cursor Up"]      = "<C-k>",
                ["Skip Region"]        = "<C-x>",
                ["Remove Region"]      = "<C-p>",
                ["Exit"]               = "<Esc>",
            }
            vim.g.VM_highlight_matches = "underline"
        end,
    },

    -- Comentarios (gcc para comentar línea, gc en visual)
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    },

    -- Autocompletado de paréntesis/comillas
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

    -- ============================================
    -- LSP Y DIAGNÓSTICOS
    -- ============================================

    -- LSP
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp").setup()
        end,
    },

    -- Mason (instalador de LSP servers)
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end,
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
                ensure_installed = { "pyright", "lua_ls" },
                automatic_installation = true,
                handlers = {},
            })
        end,
    },

    -- Trouble (lista de errores mejorada)
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({})

            -- Keymaps
            vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", {
                desc = "Toggle Trouble",
                noremap = true,
                silent = true
            })
        end,
    },

    -- ============================================
    -- FORMATEO
    -- ============================================

    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                format_on_save = {
                    timeout_ms = 1000,
                    lsp_fallback = true,
                },
                formatters_by_ft = {
                    python = { "black" },
                    lua = { "stylua" },
                    javascript = { "prettier" },
                    json = { "jq" },
                },
            })

            -- Keymaps de formateo
            vim.keymap.set({ "n", "v" }, "<leader>cf", function()
                require("conform").format({
                    async = false,
                    lsp_fallback = true,
                })
            end, { desc = "Format buffer" })

            vim.keymap.set({ "n", "v" }, "<leader>jf", function()
                require("conform").format({
                    async = false,
                    lsp_fallback = true,
                })
            end, { desc = "Format JSON" })

            vim.keymap.set({ "n", "v" }, "<leader>jm", function()
                require("conform").format({
                    async = false,
                    lsp_fallback = false,
                    formatters = { "jq" },
                })
            end, { desc = "Minify JSON" })
        end,
    },

    -- ============================================
    -- SYNTAX HIGHLIGHTING
    -- ============================================

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "python", "lua", "bash", "json",
                    "yaml", "markdown", "javascript"
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["ab"] = "@block.outer",
                            ["ib"] = "@block.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]c"] = "@class.outer",
                            ["]b"] = "@block.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]C"] = "@class.outer",
                            ["]B"] = "@block.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[c"] = "@class.outer",
                            ["[b"] = "@block.outer",
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

    -- ============================================
    -- AUTOCOMPLETADO
    -- ============================================

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
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
                    debounce = 60,
                    throttle = 30,
                    fetching_timeout = 100,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-e>"] = cmp.mapping.abort(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- ============================================
    -- TELESCOPE (BÚSQUEDA MEJORADA)
    -- ============================================

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",     -- Búsqueda más rápida
            "nvim-telescope/telescope-live-grep-args.nvim", -- Grep con argumentos
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    -- Apariencia
                    prompt_prefix = " 🔍 ",
                    selection_caret = " ➜ ",
                    entry_prefix = "  ",

                    -- Layout
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },

                    -- Ordenamiento
                    sorting_strategy = "ascending",

                    -- Preview
                    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

                    -- Comportamiento
                    file_ignore_patterns = {
                        "node_modules",
                        ".git/",
                        "%.pyc",
                        "__pycache__",
                        ".venv/",
                        "venv/",
                    },

                    -- Mappings dentro de Telescope
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<C-c>"] = actions.close, -- Ctrl+C para cerrar
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                        },
                        n = {
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["q"] = actions.close,
                            ["<C-c>"] = actions.close,
                        },
                    },
                },

                pickers = {
                    -- Configuración específica para cada picker
                    find_files = {
                        theme = "dropdown",
                        previewer = false,
                        hidden = true,
                    },

                    live_grep = {
                        theme = "ivy",
                    },

                    buffers = {
                        sort_lastused = true,
                        theme = "dropdown",
                        previewer = false,
                        mappings = {
                            i = {
                                ["<c-d>"] = actions.delete_buffer,
                            },
                            n = {
                                ["d"] = actions.delete_buffer,
                            },
                        },
                    },

                    current_buffer_fuzzy_find = {
                        theme = "ivy",
                        previewer = false,
                    },
                },

                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            -- Cargar extensiones
            telescope.load_extension("fzf")
            telescope.load_extension("noice")  -- Integración con noice
            telescope.load_extension("aerial") -- Integración con aerial

            -- ============================================
            -- KEYMAPS DE TELESCOPE
            -- ============================================
            local builtin = require("telescope.builtin")

            -- ARCHIVOS
            vim.keymap.set("n", "<C-p>", builtin.find_files, {
                desc = "Find files"
            })
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {
                desc = "Find files"
            })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, {
                desc = "Recent files"
            })

            -- BÚSQUEDA DE TEXTO
            vim.keymap.set("n", "<C-f>", builtin.live_grep, {
                desc = "Search text in project"
            })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
                desc = "Live grep"
            })

            -- BÚSQUEDA EN ARCHIVO ACTUAL (reemplaza tu /)
            vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, {
                desc = "Search in current file"
            })

            -- BÚSQUEDA DE PALABRAS
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, {
                desc = "Find word under cursor"
            })

            -- BUFFERS
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {
                desc = "Find buffers"
            })
            vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
                desc = "Find buffers (quick)"
            })

            -- GIT
            vim.keymap.set("n", "<leader>gc", builtin.git_commits, {
                desc = "Git commits"
            })
            vim.keymap.set("n", "<leader>gs", builtin.git_status, {
                desc = "Git status"
            })
            vim.keymap.set("n", "<leader>gb", builtin.git_branches, {
                desc = "Git branches"
            })

            -- LSP
            vim.keymap.set("n", "<leader>lr", builtin.lsp_references, {
                desc = "LSP References"
            })
            vim.keymap.set("n", "<leader>ld", builtin.lsp_definitions, {
                desc = "LSP Definitions"
            })
            vim.keymap.set("n", "<leader>ls", builtin.lsp_document_symbols, {
                desc = "LSP Document Symbols"
            })
            vim.keymap.set("n", "<leader>lw", builtin.lsp_workspace_symbols, {
                desc = "LSP Workspace Symbols"
            })

            -- HELP & CONFIG
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
                desc = "Help tags"
            })
            vim.keymap.set("n", "<leader>fk", builtin.keymaps, {
                desc = "Find keymaps"
            })
            vim.keymap.set("n", "<leader>fc", builtin.commands, {
                desc = "Find commands"
            })
            vim.keymap.set("n", "<leader>fch", builtin.command_history, {
                desc = "Command history"
            })

            -- DIAGNÓSTICOS
            vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {
                desc = "Find diagnostics"
            })

            -- COLORSCHEMES
            vim.keymap.set("n", "<leader>fC", builtin.colorscheme, {
                desc = "Change colorscheme"
            })

            -- NOICE (Mensajes y notificaciones)
            vim.keymap.set("n", "<leader>fn", ":Telescope noice<CR>", {
                desc = "Noice messages"
            })
        end,
    },

    -- Extensión FZF para Telescope (hace búsquedas más rápidas)
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },

    -- ============================================
    -- DEBUGGING (nvim-dap)
    -- ============================================

    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "mfussenegger/nvim-dap-python",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Configurar UI del debugger
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks",      size = 0.25 },
                            { id = "watches",     size = 0.25 },
                        },
                        size = 40,
                        position = "left",
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        size = 10,
                        position = "bottom",
                    },
                },
            })

            -- Configurar DAP para Python
            require("dap-python").setup("python") -- Usa el python del sistema/virtualenv

            -- Abrir/cerrar UI automáticamente
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Símbolos visuales para breakpoints
            vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "DapStoppedLine", numhl = "" })

            -- Keymaps para debugging
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dB", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "Conditional Breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
            vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle Debug UI" })
        end,
    },

    -- ============================================
    -- CODE FOLDING (nvim-ufo)
    -- ============================================

    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufRead",
        config = function()
            -- Configuración de vim para folding
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            require("ufo").setup({
                provider_selector = function()
                    return { "treesitter", "indent" }
                end,
            })

            -- Keymaps para folding
            vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
            vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds (except kinds)" })
            vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level" })

            -- Preview del fold al hacer hover
            vim.keymap.set("n", "K", function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end, { desc = "Peek fold or hover" })
        end,
    },

    -- ============================================
    -- UTILIDADES VISUALES
    -- ============================================

    -- TODO comments (highlight de TODO, FIXME, etc.)
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufRead",
        config = function()
            require("todo-comments").setup({
                signs = true,
                keywords = {
                    FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                    TODO = { icon = " ", color = "info" },
                    HACK = { icon = " ", color = "warning" },
                    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                },
                highlight = {
                    before = "",
                    keyword = "wide",
                    after = "fg",
                },
            })

            -- Keymaps
            vim.keymap.set("n", "]t", function()
                require("todo-comments").jump_next()
            end, { desc = "Next TODO" })

            vim.keymap.set("n", "[t", function()
                require("todo-comments").jump_prev()
            end, { desc = "Previous TODO" })

            vim.keymap.set("n", "<leader>ft", ":TodoTelescope<CR>", {
                desc = "Find TODOs"
            })
        end,
    },

    -- Colorizer (ver colores en el código)
    {
        "norcalli/nvim-colorizer.lua",
        event = "BufRead",
        config = function()
            require("colorizer").setup({
                "*", -- Activar en todos los archivos
            }, {
                RGB = true,
                RRGGBB = true,
                names = true,
                RRGGBBAA = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true,
            })
        end,
    },

    -- Noice.nvim (UI mejorado para comandos, notificaciones y mensajes)
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- Override markdown rendering para que funcione con LSP
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                -- Presets para configuración rápida
                presets = {
                    bottom_search = true,         -- Búsqueda en la parte inferior
                    command_palette = true,       -- Paleta de comandos centrada
                    long_message_to_split = true, -- Mensajes largos en split
                    inc_rename = false,           -- Input para renombrar
                    lsp_doc_border = true,        -- Bordes en documentación LSP
                },
                -- Configuración de comandos
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup", -- Vista popup (lo que querías!)
                    format = {
                        cmdline = { pattern = "^:", icon = "", lang = "vim" },
                        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                    },
                },
                -- Configuración de mensajes
                messages = {
                    enabled = true,
                    view = "notify",
                    view_error = "notify",
                    view_warn = "notify",
                    view_history = "messages",
                    view_search = "virtualtext",
                },
                -- Rutas de notificaciones
                routes = {
                    {
                        filter = {
                            event = "msg_show",
                            kind = "",
                            find = "written",
                        },
                        opts = { skip = true },
                    },
                },
            })

            -- Configurar nvim-notify (notificaciones bonitas)
            require("notify").setup({
                background_colour = "#000000",
                fps = 30,
                icons = {
                    DEBUG = "",
                    ERROR = "",
                    INFO = "",
                    TRACE = "✎",
                    WARN = ""
                },
                level = 2,
                minimum_width = 50,
                render = "default",
                stages = "fade_in_slide_out",
                timeout = 3000,
                top_down = true,
            })
        end,
    },

    -- Aerial (vista de símbolos mejorada - más moderna que symbols-outline)
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup({
                -- Layout
                layout = {
                    max_width = { 40, 0.2 },
                    width = nil,
                    min_width = 20,
                    default_direction = "prefer_right", -- Puede ser "prefer_left", "prefer_right", "left", "right", "float"
                    placement = "window",
                },

                -- Attach automáticamente cuando abres un archivo
                attach_mode = "window",

                -- Cerrar automáticamente cuando saltas a un símbolo
                close_on_select = false,

                -- Highlight del símbolo bajo el cursor
                highlight_on_hover = true,
                highlight_on_jump = 300,

                -- Guides (líneas que conectan símbolos)
                guides = {
                    mid_item = "├─",
                    last_item = "└─",
                    nested_top = "│ ",
                    whitespace = "  ",
                },

                -- Filtros (qué símbolos mostrar)
                filter_kind = {
                    "Class",
                    "Constructor",
                    "Enum",
                    "Function",
                    "Interface",
                    "Module",
                    "Method",
                    "Struct",
                },

                -- Keymaps dentro de aerial
                keymaps = {
                    ["?"] = "actions.show_help",
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.jump",
                    ["<2-LeftMouse>"] = "actions.jump",
                    ["<C-v>"] = "actions.jump_vsplit",
                    ["<C-s>"] = "actions.jump_split",
                    ["p"] = "actions.scroll",
                    ["<C-j>"] = "actions.down_and_scroll",
                    ["<C-k>"] = "actions.up_and_scroll",
                    ["j"] = "actions.next",
                    ["k"] = "actions.prev",
                    ["{"] = "actions.prev_up",
                    ["}"] = "actions.next_up",
                    ["[["] = "actions.prev_up",
                    ["]]"] = "actions.next_up",
                    ["q"] = "actions.close",
                    ["o"] = "actions.tree_toggle",
                    ["za"] = "actions.tree_toggle",
                    ["O"] = "actions.tree_toggle_recursive",
                    ["zA"] = "actions.tree_toggle_recursive",
                    ["l"] = "actions.tree_open",
                    ["zo"] = "actions.tree_open",
                    ["L"] = "actions.tree_open_recursive",
                    ["zO"] = "actions.tree_open_recursive",
                    ["h"] = "actions.tree_close",
                    ["zc"] = "actions.tree_close",
                    ["H"] = "actions.tree_close_recursive",
                    ["zC"] = "actions.tree_close_recursive",
                    ["zr"] = "actions.tree_increase_fold_level",
                    ["zR"] = "actions.tree_open_all",
                    ["zm"] = "actions.tree_decrease_fold_level",
                    ["zM"] = "actions.tree_close_all",
                    ["zx"] = "actions.tree_sync_folds",
                    ["zX"] = "actions.tree_sync_folds",
                },

                -- Iconos personalizados
                icons = {
                    Array = "󰅪 ",
                    Boolean = "◩ ",
                    Class = "𝓒 ",
                    Constant = "󰏿 ",
                    Constructor = " ",
                    Enum = " ",
                    EnumMember = " ",
                    Event = " ",
                    Field = " ",
                    File = " ",
                    Function = "󰊕 ",
                    Interface = " ",
                    Key = " ",
                    Method = "󰊕 ",
                    Module = " ",
                    Namespace = "󰦮 ",
                    Null = " ",
                    Number = "󰎠 ",
                    Object = " ",
                    Operator = " ",
                    Package = " ",
                    Property = " ",
                    String = " ",
                    Struct = " ",
                    TypeParameter = "󰗴 ",
                    Variable = "󰀫 ",
                },

                -- Integración con LSP
                lsp = {
                    diagnostics_trigger_update = true,
                    update_when_errors = true,
                    update_delay = 300,
                },

                -- Integración con Treesitter
                treesitter = {
                    update_delay = 300,
                },

                -- Opciones de ventana flotante
                float = {
                    border = "rounded",
                    relative = "cursor",
                    max_height = 0.9,
                    height = nil,
                    min_height = { 8, 0.1 },
                    override = function(conf, source_winid)
                        return conf
                    end,
                },
            })

            -- Keymaps principales
            vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", {
                desc = "Toggle Aerial (symbols)"
            })

            -- Abrir en ventana flotante (COMO TU JEFE)
            vim.keymap.set("n", "<leader>so", "<cmd>AerialToggle! float<CR>", {
                desc = "Toggle Aerial Float"
            })

            -- Navegar entre símbolos (preserva { } nativo de Vim)
            vim.keymap.set("n", "<leader>[", "<cmd>AerialPrev<CR>", {
                desc = "Previous symbol"
            })
            vim.keymap.set("n", "<leader>]", "<cmd>AerialNext<CR>", {
                desc = "Next symbol"
            })

            -- Abrir Aerial con Telescope (SÚPER COOL)
            vim.keymap.set("n", "<leader>fs", "<cmd>Telescope aerial<CR>", {
                desc = "Find symbols (Telescope)"
            })
        end,
    },

    -- ============================================
    -- WHICH-KEY (PARA RECORDAR SHORTCUTS)
    -- ============================================

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")

            wk.setup({
                preset = "modern",
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                },
                icons = {
                    breadcrumb = "»",
                    separator = "➜",
                    group = "+",
                },
                win = {
                    border = "rounded",
                    padding = { 2, 2, 2, 2 },
                },
                -- Activar which-key solo con estos prefijos importantes
                triggers = {
                    { "<leader>", mode = { "n", "v" } }, -- Tu tecla principal
                    { "]",        mode = { "n" } },      -- Navegación siguiente
                    { "[",        mode = { "n" } },      -- Navegación anterior
                },
            })

            -- Registrar grupos de teclas (nueva sintaxis)
            wk.add({
                -- Leader groups
                { "<leader>f",        group = "find" },
                { "<leader>c",        group = "code" },
                { "<leader>g",        group = "git" },
                { "<leader>h",        group = "git hunks" },
                { "<leader>j",        group = "json" },
                { "<leader>m",        group = "multi-cursor" },
                { "<leader>x",        group = "diagnostics" },
                { "<leader>d",        group = "debug" },
                { "<leader>w",        group = "workspace" },
                { "<leader>s",        group = "symbols" },
                { "<leader>l",        group = "lsp" },
                { "<leader>n",        group = "neo-tree" },

                -- Navegación (ya están definidos en la config, solo los documentamos)
                { "]c",               desc = "Next git hunk" },
                { "[c",               desc = "Previous git hunk" },
                { "]m",               desc = "Next function start" },
                { "[m",               desc = "Previous function start" },
                { "]b",               desc = "Next block" },
                { "[b",               desc = "Previous block" },
                { "]t",               desc = "Next TODO" },
                { "[t",               desc = "Previous TODO" },

                -- Navegación de símbolos
                { "<leader>]",        desc = "Next symbol" },
                { "<leader>[",        desc = "Previous symbol" },

                -- Atajos con Ctrl (documentar los existentes)
                { "<C-n>",            desc = "Toggle Neo-tree" },
                { "<C-p>",            desc = "Find files (Telescope)" },
                { "<C-f>",            desc = "Search text in files" },

                -- Multi-cursor (vim-visual-multi)
                { "<C-j>",            desc = "Add cursor down",        mode = "n" },
                { "<C-k>",            desc = "Add cursor up",          mode = "n" },

                -- Funciones tecla (F-keys) para debugging
                { "<F5>",             desc = "Debug: Start/Continue" },
                { "<F10>",            desc = "Debug: Step Over" },
                { "<F11>",            desc = "Debug: Step Into" },
                { "<F12>",            desc = "Debug: Step Out" },

                -- Búsqueda en archivo actual
                { "<leader>/",        desc = "Search in current file" },

                -- Buffers rápido
                { "<leader><leader>", desc = "Switch buffers" },

                -- Aerial (símbolos)
                { "<leader>a",        desc = "Toggle Aerial" },

                -- Neo-tree flotante (COMO TU JEFE)
                { "<leader>e",        desc = "Neo-tree Float" },
            })
        end,
    },
})
