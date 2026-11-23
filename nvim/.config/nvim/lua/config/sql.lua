-- ~/.config/nvim/lua/config/sql.lua
--
-- Flujo rápido de queries sobre vim-dadbod / dadbod-ui.
--
-- El flujo del drawer (DBUI -> conexión -> tabla -> helper) es cómodo para
-- explorar el schema, pero lento para "abrir algo y tirar una query". Este
-- módulo agrega dos atajos:
--
--   <leader>Dq     abre un scratch .sql ya conectado, sin pasar por el drawer
--   <leader><CR>   ejecuta SOLO la sentencia bajo el cursor
--
-- Lo segundo importa en Redshift: el <leader>S de dadbod-ui en modo normal
-- manda el buffer COMPLETO, así que un scratch con varias queries obliga a
-- seleccionar en visual cada vez (o a lanzar todo sin querer).

local M = {}

-- ============================================
-- Helpers internos
-- ============================================

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "dadbod" })
end

local function feed(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "mx", false)
end

-- dadbod-ui solo define <Plug>(DBUI_ExecuteQuery) en los buffers que él mismo
-- administra (los del drawer o los adoptados con :DBUIFindBuffer). Si existe lo
-- reusamos: trae bind params, cronómetro de query y registro del buffer.
local function has_dbui_exec(mode)
    return vim.fn.maparg("<Plug>(DBUI_ExecuteQuery)", mode) ~= ""
end

local function connected()
    local db = vim.b.db
    if db == nil or db == "" then
        notify("Buffer sin conexión. Usa <leader>Dq (scratch nuevo) o <leader>Df (adoptar este buffer).",
            vim.log.levels.WARN)
        return false
    end
    return true
end

-- ============================================
-- Sentencia bajo el cursor
-- ============================================

-- Delimitadores: un `;` al final de línea o una línea en blanco. Es heurística
-- (no parsea strings ni comentarios), pero cubre el 99% de un scratch.
local function statement_range()
    local last = vim.fn.line("$")
    local cur = vim.fn.line(".")

    local function blank(n)
        return vim.fn.getline(n):match("^%s*$") ~= nil
    end
    local function terminator(n)
        return vim.fn.getline(n):match(";%s*$") ~= nil
    end

    -- Cursor en línea vacía: engancha la sentencia de abajo, si no la de arriba.
    if blank(cur) then
        local n = cur
        while n <= last and blank(n) do
            n = n + 1
        end
        if n > last then
            n = cur
            while n >= 1 and blank(n) do
                n = n - 1
            end
        end
        if n < 1 or n > last then
            return nil
        end
        cur = n
    end

    local s = cur
    while s > 1 and not blank(s - 1) and not terminator(s - 1) do
        s = s - 1
    end

    local e = cur
    while e < last and not terminator(e) and not blank(e + 1) do
        e = e + 1
    end

    return s, e
end

--- Ejecuta la sentencia SQL donde está el cursor.
function M.exec_statement()
    if not connected() then
        return
    end

    local s, e = statement_range()
    if not s then
        return notify("No hay sentencia bajo el cursor", vim.log.levels.WARN)
    end

    if has_dbui_exec("v") then
        -- Seleccionamos el rango y disparamos el ejecutor de dadbod-ui, que lee
        -- la selección visual (necesita estar en visual, por eso el feedkeys).
        feed(string.format("%dGV%dG", s, e) .. "<Plug>(DBUI_ExecuteQuery)")
    else
        vim.cmd(string.format("silent %d,%dDB", s, e))
    end
end

--- Ejecuta la selección visual.
function M.exec_selection()
    if not connected() then
        return
    end

    if has_dbui_exec("v") then
        feed("<Plug>(DBUI_ExecuteQuery)")
        return
    end

    -- Salir de visual fija las marcas '< y '>, que es lo que lee el rango de :DB.
    feed("<Esc>")
    vim.cmd("silent '<,'>DB")
end

--- Ejecuta el buffer completo.
function M.exec_buffer()
    if not connected() then
        return
    end

    if has_dbui_exec("n") then
        feed("<Plug>(DBUI_ExecuteQuery)")
    else
        vim.cmd("silent %DB")
    end
end

-- ============================================
-- Scratch buffers
-- ============================================

local function connections()
    -- Si se entra por :lua en vez de por <leader>Dq, dadbod-ui puede seguir sin
    -- cargar y su autoload no existiría todavía.
    if vim.fn.exists("*db_ui#connections_list") == 0 then
        pcall(function()
            require("lazy").load({ plugins = { "vim-dadbod-ui" } })
        end)
    end

    local ok, list = pcall(vim.fn["db_ui#connections_list"])
    if not ok or type(list) ~= "table" then
        return {}
    end
    return list
end

local function pick_connection(cb)
    local conns = connections()
    if vim.tbl_isempty(conns) then
        return notify("No hay conexiones guardadas. Agrega una con <leader>Da.", vim.log.levels.WARN)
    end
    if #conns == 1 then
        return cb(conns[1])
    end
    vim.ui.select(conns, {
        prompt = "Conexión:",
        format_item = function(c)
            return (c.is_connected == 1 and "● " or "○ ") .. c.name
        end,
    }, function(choice)
        if choice then
            cb(choice)
        end
    end)
end

-- El archivo vive en db_ui_tmp_query_location y DEBE empezar con el nombre de
-- la conexión: dadbod-ui reasocia los scratch viejos a su conexión comparando
-- ese prefijo, así siguen apareciendo en el drawer tras reiniciar nvim.
local function scratch_path(name)
    local dir = vim.g.db_ui_tmp_query_location
    vim.fn.mkdir(dir, "p")
    local slug = name:gsub("[^%w%-_]", "-")
    return string.format("%s/%s-scratch-%s.sql", dir, slug, os.date("%Y%m%d-%H%M%S"))
end

--- Abre un scratch .sql ya conectado. `opts.split` = comando de ventana.
function M.new_query(opts)
    opts = opts or {}
    pick_connection(function(conn)
        vim.cmd((opts.split or "vsplit") .. " " .. vim.fn.fnameescape(scratch_path(conn.name)))
        vim.bo.filetype = "sql"
        vim.b.db = conn.url

        -- Este buffer no lo administra dadbod-ui, así que su ftplugin dejó
        -- <leader>S apuntando a un <Plug> inexistente: lo reemplazamos.
        local o = { buffer = true, silent = true }
        vim.keymap.set("n", "<leader>S", M.exec_buffer, vim.tbl_extend("force", o, { desc = "SQL: ejecutar buffer" }))
        vim.keymap.set("x", "<leader>S", M.exec_selection, vim.tbl_extend("force", o, { desc = "SQL: ejecutar selección" }))

        if vim.fn.exists("*vim_dadbod_completion#fetch") == 1 then
            vim.fn["vim_dadbod_completion#fetch"](vim.api.nvim_get_current_buf())
        end

        notify("Scratch conectado a " .. conn.name .. " — <leader><CR> ejecuta la sentencia bajo el cursor")
    end)
end

-- ============================================
-- Cierre de buffers
-- ============================================

-- Los scratch de <leader>Dq y los resultados de dadbod-ui quedan "modified"
-- en cuanto escribes algo o corre una query (aunque el archivo en disco esté
-- igual), así que :bd pide `!` cada vez. Este atajo cierra el buffer actual
-- sin esa fricción; no hay nada de valor que perder en un scratch.
function M.close_buffer()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd("bdelete! " .. buf)
end

local function is_disposable(bufnr)
    local ft = vim.bo[bufnr].filetype
    return ft == "sql" or ft == "mysql" or ft == "plsql" or ft == "dbout"
end

-- El `d`/<C-d> del picker de buffers de Telescope llama a actions.delete_buffer,
-- que solo fuerza el borrado en buffers terminal; para scratch/dbout (modified)
-- el force=false falla en silencio (pcall interno de Telescope) y el buffer
-- se queda en la lista. Le quitamos 'modified' antes de delegar en la acción
-- normal para que borre limpio y conserve su lógica de reemplazo de buffer.
function M.telescope_delete_buffer(prompt_bufnr)
    local ok_state, action_state = pcall(require, "telescope.actions.state")
    local selection = ok_state and action_state.get_selected_entry()
    if selection and selection.bufnr and is_disposable(selection.bufnr) then
        vim.bo[selection.bufnr].modified = false
    end
    require("telescope.actions").delete_buffer(prompt_bufnr)
end

--- Mapeos que aplican a un buffer SQL (scratch, del drawer o del repo).
--- `opts.exec = false` omite <leader><CR>: lo usan los buffers de resultados
--- (filetype dbout), que son de solo lectura y no tienen sentencia que ejecutar.
function M.attach(opts)
    opts = opts or {}
    local o = { buffer = true, silent = true }

    if opts.exec ~= false then
        vim.keymap.set("n", "<leader><CR>", M.exec_statement,
            vim.tbl_extend("force", o, { desc = "SQL: ejecutar sentencia bajo el cursor" }))
        vim.keymap.set("x", "<leader><CR>", M.exec_selection,
            vim.tbl_extend("force", o, { desc = "SQL: ejecutar selección" }))
    end

    vim.keymap.set("n", "<leader>Dd", M.close_buffer,
        vim.tbl_extend("force", o, { desc = "SQL: cerrar buffer" }))
end

return M
