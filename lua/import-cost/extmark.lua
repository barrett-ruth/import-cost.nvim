local M = {}

local ic, job, util =
    require 'import-cost', require 'import-cost.job', require 'import-cost.util'

local cache = {}

local function update_cache(bufnr, data, extmark_id)
    if not cache[bufnr] then
        cache[bufnr] = {}
    end

    cache[bufnr][data.string] = data
    cache[bufnr][data.string].extmark_id = extmark_id
end

local function set_extmark(bufnr, data)
    local string = util.normalize_string(data.string)

    if cache[bufnr] and cache[bufnr][string] then
        return
    end

    data.string = string
    local extmark_id = job.render_extmark(bufnr, data)
    update_cache(bufnr, data, extmark_id)
end

function M.set_extmarks(bufnr)
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

                if data and data.size then
                    set_extmark(bufnr, data)
                end
            end
        end,
    })

    job.stop_prev_job(job_id, bufnr)
    job.send_buf_contents(job_id, bufnr)
end

function M.clear_extmarks(bufnr)
    if cache[bufnr] then
        cache[bufnr] = nil
    end

    vim.api.nvim_buf_clear_namespace(bufnr, ic.ns_id, 0, -1)
end

function M.delete_extmarks(bufnr)
    if not cache[bufnr] then
        return
    end

    for string, data in pairs(cache[bufnr]) do
        if
            string
            == util.normalize_string(
                vim.api.nvim_buf_get_text(
                    bufnr,
                    data.line - 1,
                    0,
                    data.line - 1,
                    -1,
                    {}
                )[1]
            )
        then
            goto continue
        else
            vim.api.nvim_buf_del_extmark(bufnr, ic.ns_id, data.extmark_id)
            cache[bufnr][string] = nil
        end

        ::continue::
    end
end

return M
