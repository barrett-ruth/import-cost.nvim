local M = {}

local function is_ic_buf(bufnr)
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    return vim.tbl_contains(M.config.filetypes, filetype)
end

local function au(events, cb)
    vim.api.nvim_create_autocmd(events, {
        callback = function(opts)
            if is_ic_buf(opts.buf) then
                cb(opts)
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
    },
    format = {
        byte_format = '%.2f b',
        kb_format = '%.2f kb',
        virtual_text = '%s (gzipped: %s)',
    },
    highlight = 'Comment',
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend('force', M.config, user_config or {})

    M.ns_id = vim.api.nvim_create_namespace 'ImportCost'

    M.script_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')
        .. '/import-cost/index.js'

    vim.api.nvim_set_hl(
        0,
        'ImportCostVirtualText',
        ---@diagnostic disable-next-line: param-type-mismatch
        type(M.config.highlight) == 'string' and { link = M.config.highlight }
            or M.config.highlight
    )

    M.aug_id = vim.api.nvim_create_augroup('ImportCost', {})

    local extmark = require 'import-cost.extmark'

    au({ 'BufEnter', 'BufWritePost' }, function(opts)
        extmark.set_missing_extmarks(opts.buf)
    end)

    au('TextChanged', function(opts)
        extmark.update_extmarks(opts.buf)
    end)
end

return M
