-- Archivo: ~/.config/nvim/lua/config/lsp.lua

local M = {}

-- Función para configurar los atajos de LSP
M.on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    -- Atajos de teclado para LSP
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)      -- Ir a definición
    buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)    -- Ir a declaración
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- Ir a implementación
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)     -- Buscar referencias
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)           -- Mostrar información flotante
    buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) -- Renombrar
    buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) -- Acciones de código
    buf_set_keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)   -- Diagnóstico anterior
    buf_set_keymap("n", "<leader>n", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)   -- Diagnóstico siguiente
    buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- Mostrar diagnóstico flotante
    buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts) -- Lista de diagnósticos

    local navic_ok, navic = pcall(require, "nvim-navic")
    if navic_ok and client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

end


-- Configuración para servidores LSP
M.setup = function()
  -- Capabilities de cmp-nvim-lsp
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  capabilities.offsetEncoding = { "utf-8" }
  capabilities.general = capabilities.general or {}
  capabilities.general.positionEncodings = { "utf-8" }

  local on_attach = M.on_attach

  -- 1) Definir configs (SIN .setup)
  vim.lsp.config["pyright"] = {
    settings = {
      python = {
        analysis = {
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = false,
          typeCheckingMode = "basic",
        },
      },
    },
    capabilities = capabilities,
    on_attach = on_attach,
  }

  vim.lsp.config["ruff"] = {
    init_options = {
      settings = {
        args = {}, -- p.ej. { "--line-length=88" }
      },
    },
    capabilities = capabilities,
    on_attach = on_attach,
  }

  -- 2) Habilitar los servers
  vim.lsp.enable({ "pyright", "ruff" })
end

return M
