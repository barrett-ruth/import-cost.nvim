local M = {}

local ic, job, util =
    require 'import-cost', require 'import-cost.job', require 'import-cost.util'

local visible_strings = {}

local function update_visible_strings(bufnr, data, extmark_id)
    if not visible_strings[bufnr] then
        visible_strings[bufnr] = {}
    end

    visible_strings[bufnr][data.string] = data
    visible_strings[bufnr][data.string].extmark_id = extmark_id
end

local function string_visible(bufnr, string)
    return visible_strings[bufnr] and visible_strings[bufnr][string]
end

function M.set_missing_extmarks(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    local cmd = { 'node', ic.script_path, path, filetype }

    local job_id = vim.fn.jobstart(cmd, {
        on_stdout = function(_, stdout, _)
            if not stdout or stdout[1] == '' then
                return
            end

            local chunks = vim.split(stdout[1], '|', { trimempty = true })

            for _, chunk in ipairs(chunks) do
                local data = util.parse_data(chunk)

                if util.is_ok(data) then
                    local string = util.normalize_string(data.string)

                    if not string_visible(bufnr, string) then
                        data.string = string

                        local extmark_id = job.set_extmark(bufnr, data)

                        update_visible_strings(bufnr, data, extmark_id)
                    end
                end
            end
        end,
    })

    job.stop_prev_job(job_id, bufnr)
    job.send_buf_contents(job_id, bufnr)
end

function M.clear_extmarks(bufnr)
    if visible_strings[bufnr] then
        visible_strings[bufnr] = nil
    end

    vim.api.nvim_buf_clear_namespace(bufnr, ic.ns_id, 0, -1)
end

function M.update_extmarks(bufnr)
    local buffer_strings = M.move_existing_extmarks(bufnr)
    M.delete_remaining_extmarks(bufnr, buffer_strings)
    M.set_missing_extmarks(bufnr)
end

function M.move_existing_extmarks(bufnr)
    local buffer_strings = {}

    for nr, raw_string in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)) do
        if util.is_import_string(raw_string) then
            local string = util.normalize_string(raw_string)
            local data = visible_strings[bufnr][string]

            buffer_strings[string] = true

            if data and data.string == string then
                if data.line ~= nr then
                    data.line = nr

                    job.set_extmark(bufnr, data, data.extmark_id)
                end
            end
        end
    end

    return buffer_strings
end

function M.delete_remaining_extmarks(bufnr, buffer_strings)
    for string, data in pairs(visible_strings[bufnr]) do
        if not buffer_strings[string] then
            vim.api.nvim_buf_del_extmark(bufnr, ic.ns_id, data.extmark_id)

            visible_strings[bufnr][string] = nil
        end
    end
end

return M
