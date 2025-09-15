local wezterm = require('wezterm')

local utils = {}

utils.is_windows_platform = wezterm.target_triple:find("windows") ~= nil
utils.directory_separator = utils.is_windows_platform and "\\" or "/"

function utils.log_plugin_error(message)
    wezterm.log_error("[image-handler] " .. message)
end

function utils.log_plugin_warning(message)
    wezterm.log_warn("[image-handler] " .. message)
end

function utils.log_plugin_info(message)
    wezterm.log_info("[image-handler] " .. message)
end

function utils.verify_file_exists_at_path(file_path)
    if not file_path or file_path == "" then
        return false
    end
    
    local file_open_successful, file_handle = pcall(io.open, file_path, "r")
    if file_open_successful and file_handle then
        file_handle:close()
        return true
    end
    return false
end

function utils.verify_directory_exists_at_path(directory_path)
    if not directory_path or directory_path == "" then
        return false
    end
    
    local platform_check_command
    if utils.is_windows_platform then
        platform_check_command = 'dir "' .. directory_path .. '" >nul 2>nul && echo exists'
    else
        platform_check_command = 'test -d "' .. directory_path .. '" && echo "exists"'
    end
    
    local command_successful, command_handle = pcall(io.popen, platform_check_command)
    if not command_successful or not command_handle then
        return false
    end
    
    local command_output = command_handle:read("*a")
    command_handle:close()
    return command_output and command_output:match("exists")
end

return utils