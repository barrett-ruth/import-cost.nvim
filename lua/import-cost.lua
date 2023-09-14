local M = {}

local function is_ic_buf(bufnr)
    local ok, filetype = pcall(vim.api.nvim_buf_get_option, bufnr, 'filetype')

    if not ok then
        return false
    end

    return vim.tbl_contains(M.config.filetypes, filetype)
end

local function au(events, cb)
    vim.api.nvim_create_autocmd(events, {
        callback = function(opts)
            if is_ic_buf(opts.buf) then
                cb(opts.buf)
            end
        end,
        group = M.aug_id,
    })
end

M.config = {
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte'
    },
    format = {
        byte_format = '%.1fb',
        kb_format = '%.1fk',
        virtual_text = '%s (gzipped: %s)',
    },
    highlight = 'Comment',
}

M.setup = function(user_config)
    M.script_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')
        .. '/import-cost/index.js'

    if not vim.loop.fs_stat(M.script_path) then
        vim.notify_once(
            string.format(
                'import-cost.nvim: Failed to load script at %s. Ensure the plugin is properly installed.',
                M.script_path
            ),
            vim.log.levels.ERROR
        )
        return
    end

    M.config = vim.tbl_deep_extend('force', M.config, user_config or {})

    M.ns_id = vim.api.nvim_create_namespace 'ImportCost'

    vim.api.nvim_set_hl(
        0,
        'ImportCostVirtualText',
        ---@diagnostic disable-next-line: param-type-mismatch
        type(M.config.highlight) == 'string' and { link = M.config.highlight }
            or M.config.highlight
    )

    M.aug_id = vim.api.nvim_create_augroup('ImportCost', {})

    local extmark = require 'import-cost.extmark'

    au('BufEnter', function(bufnr)
        extmark.set_extmarks(bufnr)
    end)

    au('InsertEnter', function(bufnr)
        extmark.delete_extmarks(bufnr)
    end)

    au('InsertLeave', function(bufnr)
        extmark.set_extmarks(bufnr)
    end)

    au('TextChanged', function(bufnr)
        extmark.delete_extmarks(bufnr)
        extmark.set_extmarks(bufnr)
    end)
end

return M
