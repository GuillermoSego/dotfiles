-- ~/.config/nvim/lua/config/lsp.lua
local M = {}

-- Opciones compartidas para las ventanas flotantes de hover/signature help.
-- En Nvim 0.12 `vim.lsp.with()` fue removido: el borde se pasa directo a
-- `vim.lsp.buf.hover()` / `vim.lsp.buf.signature_help()`.
M.float_opts = { border = "rounded" }

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
    -- K is mapped by nvim-ufo with fallback to hover, so we skip it here
    local function signature_help()
        vim.lsp.buf.signature_help(M.float_opts)
    end
    map("n", "<C-k>", signature_help, "Show signature help")
    map("i", "<C-k>", signature_help, "Show signature help")

    -- ===== REFACTORING =====
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
    map("v", "<leader>ca", vim.lsp.buf.code_action, "Code actions")

    -- ===== DIAGNÓSTICOS =====
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>xd", vim.diagnostic.open_float, "Show diagnostic float")
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

    -- LSP attached (silencioso para no spammear con noice.nvim)
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
-- Colores atenuados para el texto virtual: mantienen el matiz Cyberdream
-- pero mezclados con el fondo para que no compitan con el código resaltado.
local dim_colors = {
    Error = "#a15a52",
    Warn  = "#9a9a52",
    Info  = "#4e8996",
    Hint  = "#4e8f61",
    Ok    = "#4e8f61",
}

-- Tinte de fondo sobre el token marcado: el color del editor (#16181a) con un
-- ~10% del matiz de la severidad. Terminal.app sí dibuja fondos de 24 bits con
-- precisión, así que estos valores llegan exactos y no aproximados.
local tint_colors = {
    Error = "#2a1c1c",
    Warn  = "#262417",
    Info  = "#16222a",
    Hint  = "#16221a",
    Ok    = "#16221a",
}

-- Terminal.app no soporta undercurl (`CSI 4:3 m`) ni color de subrayado
-- (`CSI 58 ...`). tmux.conf los anuncia vía Smulx/Setulc, así que Neovim los
-- emite y Terminal.app los dibuja mal, tapando el texto. Con `false` usamos
-- subrayado plano, soportado en todas partes. Ponlo en `true` si cambias a
-- Ghostty / iTerm2 / kitty / WezTerm.
local has_undercurl = false

local function dim_diagnostic_highlights()
    for level, color in pairs(dim_colors) do
        -- Texto virtual al final de la línea: tenue, sin fondo.
        vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. level, {
            fg = color,
            bg = "NONE",
            italic = true,
        })
        -- Marca sobre el token. Nunca se define `fg` aquí: así el color de
        -- Treesitter sobrevive y el código sigue legible.
        if has_undercurl then
            vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. level, {
                undercurl = true,
                sp = color,
            })
        else
            vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. level, {
                bg = tint_colors[level],
            })
        end
    end

    -- Ruff/Pyright marcan casi todo con el tag `unnecessary`, y Nvim pinta
    -- DiagnosticUnnecessary encima del token con prioridad 152, por encima de
    -- Treesitter (100). Si el grupo define `fg`, repinta la palabra de gris y
    -- tapa el resaltado de sintaxis. Sin `fg` los atributos se combinan: el
    -- token conserva su color y solo se marca en cursiva.
    vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { italic = true })

    -- Mismo motivo: que "deprecated" tache el texto sin recolorearlo.
    vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = true })
end

M.setup_diagnostics = function()
    -- Configuración global de diagnósticos
    vim.diagnostic.config({
        virtual_text = {
            prefix = "●",
            source = "if_many", -- Mostrar fuente si hay múltiples
            spacing = 4,
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN]  = "",
                [vim.diagnostic.severity.HINT]  = "",
                [vim.diagnostic.severity.INFO]  = "",
            },
        },
        underline = true,
        update_in_insert = false, -- No actualizar en modo insert
        severity_sort = true,     -- Ordenar por severidad
        float = {
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
        },
    })

    -- Aplicar ahora y re-aplicar cada vez que cambie el colorscheme,
    -- porque el tema restablece los grupos Diagnostic*.
    dim_diagnostic_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("DimDiagnostics", { clear = true }),
        callback = dim_diagnostic_highlights,
    })
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
    vim.lsp.config["lua_ls"] = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },
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

    -- ===== GOPLS (Go) =====
    vim.lsp.config["gopls"] = {
        settings = {
            gopls = {
                -- Análisis estático completo
                analyses = {
                    unusedparams = true,
                    shadow = true,
                    nilness = true,
                    unusedwrite = true,
                    useany = true,
                },
                -- Imports automáticos al guardar
                gofumpt = true,

                -- Completions mejorados
                usePlaceholders = true,
                completeUnimported = true,

                -- Inlay hints (tipos inferidos, nombres de params)
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },

                -- Semántica de código
                semanticTokens = true,
                staticcheck = true,

                -- Build
                directoryFilters = { "-.git", "-.vscode", "-node_modules" },
            },
        },
        capabilities = capabilities,
        on_attach = on_attach,
    }

    -- ===== HABILITAR SERVIDORES =====
    vim.lsp.enable({ "pyright", "ruff", "lua_ls", "gopls" })
end

-- ============================================
-- COMANDOS ÚTILES
-- ============================================

-- Comando para reiniciar LSP
vim.api.nvim_create_user_command("LspRestart", function()
    vim.lsp.stop_client(vim.lsp.get_clients())
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
