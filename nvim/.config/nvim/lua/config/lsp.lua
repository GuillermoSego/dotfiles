-- ~/.config/nvim/lua/config/lsp.lua
local M = {}

-- ============================================
-- CONFIGURACIÓN DE KEYMAPS LSP
-- ============================================
M.on_attach = function(client, bufnr)
    -- Función helper para crear keymaps más fácil
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = desc -- Para que which-key los muestre
        })
    end

    -- ===== NAVEGACIÓN (goto) =====
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "Find references")
    map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

    -- ===== INFORMACIÓN =====
    map("n", "K", vim.lsp.buf.hover, "Show hover info")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")

    -- ===== REFACTORING =====
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
    map("v", "<leader>ca", vim.lsp.buf.code_action, "Code actions")

    -- ===== DIAGNÓSTICOS =====
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")
    map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostic list")

    -- ===== FORMATEO =====
    -- Solo si el servidor soporta formateo
    if client.server_capabilities.documentFormattingProvider then
        map("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
        end, "Format document")
    end

    -- ===== WORKSPACE =====
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")

    -- ===== INTEGRACIÓN CON NAVIC (breadcrumbs) =====
    local navic_ok, navic = pcall(require, "nvim-navic")
    if navic_ok and client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

    -- Opcional: Mostrar mensaje cuando LSP se conecta
    vim.notify(
        string.format("LSP [%s] attached to buffer %d", client.name, bufnr),
        vim.log.levels.INFO
    )
end

-- ============================================
-- CONFIGURACIÓN DE CAPABILITIES
-- ============================================
M.get_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Integración con nvim-cmp
    local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    -- Configuración de encoding
    capabilities.offsetEncoding = { "utf-8" }
    capabilities.general = capabilities.general or {}
    capabilities.general.positionEncodings = { "utf-8" }

    return capabilities
end

-- ============================================
-- CONFIGURACIÓN DE DIAGNÓSTICOS
-- ============================================
M.setup_diagnostics = function()
    -- Configuración global de diagnósticos
    vim.diagnostic.config({
        virtual_text = {
            prefix = "●",
            source = "if_many", -- Mostrar fuente si hay múltiples
        },
        signs = true,
        underline = true,
        update_in_insert = false, -- No actualizar en modo insert
        severity_sort = true,     -- Ordenar por severidad
        float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })

    -- Símbolos en el gutter
    local signs = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn",  text = "" },
        { name = "DiagnosticSignHint",  text = "" },
        { name = "DiagnosticSignInfo",  text = "" },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, {
            texthl = sign.name,
            text = sign.text,
            numhl = ""
        })
    end

    -- Handlers para ventanas flotantes con bordes redondeados
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "rounded" }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "rounded" }
    )
end

-- ============================================
-- CONFIGURACIÓN DE SERVIDORES LSP
-- ============================================
M.setup = function()
    local capabilities = M.get_capabilities()
    local on_attach = M.on_attach

    -- Configurar diagnósticos
    M.setup_diagnostics()

    -- ===== PYRIGHT (Type checking para Python) =====
    vim.lsp.config["pyright"] = {
        settings = {
            python = {
                analysis = {
                    -- Análisis más rápido: solo archivos abiertos
                    diagnosticMode = "openFilesOnly",

                    -- Usar código de librerías para tipos
                    useLibraryCodeForTypes = true,

                    -- Nivel de type checking
                    typeCheckingMode = "standard", -- "off" | "basic" | "standard" | "strict"

                    -- Desactivar warnings molestos
                    reportMissingTypeStubs = false,
                    reportUnusedImport = false,
                    reportUnusedVariable = false,

                    -- Auto-import
                    autoImportCompletions = true,
                    autoSearchPaths = true,
                },
            },
        },
        capabilities = capabilities,
        on_attach = on_attach,
    }

    -- ===== RUFF (Linting y formatting rápido para Python) =====
    vim.lsp.config["ruff"] = {
        init_options = {
            settings = {
                -- Argumentos para ruff
                args = {
                    "--line-length=88", -- Mismo que Black
                    "--select=E,F,W,I", -- Reglas: errors, pyflakes, warnings, isort
                },
                -- Organizar imports automáticamente
                organizeImports = true,
                -- Fix automático al guardar
                fixAll = true,
            },
        },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            -- Llamar al on_attach base
            on_attach(client, bufnr)

            -- Desactivar hover de Ruff (preferir Pyright)
            client.server_capabilities.hoverProvider = false
        end,
    }

    -- ===== LUA_LS (Para configurar Neovim) =====
    -- Descomenta si quieres configurar también Lua
    --[[
    vim.lsp.config["lua_ls"] = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },  -- Reconoce 'vim' como global
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
        capabilities = capabilities,
        on_attach = on_attach,
    }
    ]] --

    -- ===== HABILITAR SERVIDORES =====
    vim.lsp.enable({ "pyright", "ruff" })

    -- Si agregaste lua_ls, descoméntalo aquí también:
    -- vim.lsp.enable({ "pyright", "ruff", "lua_ls" })
end

-- ============================================
-- COMANDOS ÚTILES
-- ============================================

-- Comando para reiniciar LSP
vim.api.nvim_create_user_command("LspRestart", function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    vim.cmd("edit")
end, { desc = "Restart LSP" })

-- Comando para ver información del LSP
vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd("LspInfo")
end, { desc = "Show LSP info" })

-- Comando para ver log del LSP (útil para debugging)
vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "Open LSP log" })

return M
