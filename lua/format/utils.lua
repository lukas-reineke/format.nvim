local M = {}

function M.undojoin()
    local undojoin_count = 0
    return function()
        if undojoin_count > 0 then
            vim.api.nvim_command("silent! undojoin")
        end
        undojoin_count = undojoin_count + 1
    end
end

function M.merge_config(input_config)
    local base_formatter = {}
    local base_tempfile_postfix
    local base_tempfile_prefix
    local config = {}

    for _, c in pairs(input_config) do
        for _, v in pairs(c) do
            if v.formatter == nil or #v.formatter == 0 then
                goto continue
            end
            if v.start_pattern ~= nil and v.end_pattern ~= nil then
                table.insert(config, v)
            else
                for _, fv in pairs(v.formatter) do
                    table.insert(base_formatter, fv)
                end
                if v.tempfile_postfix ~= nil then
                    base_tempfile_postfix = v.tempfile_postfix
                end
                if v.tempfile_prefix ~= nil then
                    base_tempfile_prefix = v.tempfile_prefix
                end
            end

            ::continue::
        end
    end

    if #base_formatter > 0 then
        table.insert(
            config,
            1,
            {
                formatter = base_formatter,
                tempfile_prefix = base_tempfile_prefix,
                tempfile_postfix = base_tempfile_postfix
            }
        )
    end

    return config
end

return M