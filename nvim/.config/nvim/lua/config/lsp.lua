-- Archivo: ~/.config/nvim/lua/config/lsp.lua

local M = {}

-- Función para configurar los atajos de LSP
M.on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local opts = { noremap = true, silent = true }

	-- Atajos de teclado para LSP
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- Ir a definición
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- Ir a declaración
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- Ir a implementación
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) -- Buscar referencias
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) -- Mostrar información flotante
	buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) -- Renombrar
	buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) -- Acciones de código
	buf_set_keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts) -- Diagnóstico anterior
	buf_set_keymap("n", "<leader>n", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts) -- Diagnóstico siguiente
	buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- Mostrar diagnóstico flotante
	buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts) -- Lista de diagnósticos

	vim.keymap.set("n", "<leader>K", function()
		local params = vim.lsp.util.make_position_params(0, enc)
		vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result)
			if not (result and result.contents) then
				return
			end
			local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
			if vim.tbl_isempty(lines) then
				return
			end

			-- crea split normal (usa "vsplit" si prefieres vertical)
			vim.cmd("aboveleft split")
			local win = vim.api.nvim_get_current_win()
			local buf = vim.api.nvim_create_buf(false, true)

			vim.api.nvim_win_set_buf(win, buf)
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].modifiable = true
			vim.bo[buf].swapfile = false
			vim.bo[buf].filetype = "markdown"
			vim.wo[win].wrap = true
			vim.wo[win].conceallevel = 2
			vim.wo[win].concealcursor = "nc"

			-- aplica estilo de “hover” (resaltado markdown como el flotante)
			vim.lsp.util.stylize_markdown(buf, lines, { max_width = 80 })

			vim.bo[buf].modifiable = false
			vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
		end)
	end, { buffer = bufnr, desc = "Hover en ventana normal (estilizado)" })

	local navic_ok, navic = pcall(require, "nvim-navic")
	if navic_ok and client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end
end

-- Configuración para servidores LSP
M.setup = function()
	-- Capabilities de cmp-nvim-lsp
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	capabilities.offsetEncoding = { "utf-16" }
	capabilities.general = capabilities.general or {}
	capabilities.general.positionEncodings = { "utf-16" }

	local on_attach = M.on_attach

	-- 1) Definir configs (SIN .setup)
	vim.lsp.config["pyright"] = {
		settings = {
			python = {
				analysis = {
					diagnosticMode = "openFilesOnly",
					useLibraryCodeForTypes = true,
					typeCheckingMode = "strict",
					reportMissingTypeStubs = false,
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
