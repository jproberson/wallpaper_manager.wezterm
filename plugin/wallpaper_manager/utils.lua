local wezterm = require('wezterm')

local utils = {}

utils.is_windows_platform = wezterm.target_triple:find("windows") ~= nil
utils.directory_separator = utils.is_windows_platform and "\\" or "/"

function utils.safely_require_module(module_name)
    local success, result = pcall(require, module_name)
    if success then
        return result
    else
        wezterm.log_error("Failed to require " .. module_name .. ": " .. result)
        return nil
    end
end

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

function utils.extract_file_extension_from_path(file_path)
    return file_path:match("^.+(%..+)$"):sub(2):lower()
end

function utils.is_file_extension_supported(file_path, supported_extensions)
    local file_extension = utils.extract_file_extension_from_path(file_path)
    for _, supported_extension in ipairs(supported_extensions) do
        if file_extension == supported_extension then
            return true
        end
    end
    return false
end

return utils