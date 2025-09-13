local utils = require('wallpaper_manager.utils')
local state = require('wallpaper_manager.state')

local scanner = {}

local SUPPORTED_IMAGE_FORMATS = { "png", "jpg", "jpeg", "gif", "bmp", "ico", "tiff", "pnm", "dds", "tga" }

function scanner.scan_directory_for_supported_image_files(target_directory)
    local discovered_image_files = {}
    
    if not utils.verify_directory_exists_at_path(target_directory) then
        utils.log_plugin_warning("Image directory does not exist: " .. tostring(target_directory))
        return discovered_image_files
    end
    
    local platform_find_command
    if utils.is_windows_platform then
        local file_patterns = {}
        for _, extension in ipairs(SUPPORTED_IMAGE_FORMATS) do
            table.insert(file_patterns, "*." .. extension)
            table.insert(file_patterns, "*." .. extension:upper())
        end
        local combined_patterns = table.concat(file_patterns, " ")
        platform_find_command = string.format('dir "%s" /b /s %s 2>nul', target_directory, combined_patterns)
    else
        local name_patterns = {}
        for _, extension in ipairs(SUPPORTED_IMAGE_FORMATS) do
            table.insert(name_patterns, string.format('-name "*.%s"', extension))
            table.insert(name_patterns, string.format('-name "*.%s"', extension:upper()))
        end
        local combined_patterns = table.concat(name_patterns, " -o ")
        platform_find_command = string.format('find "%s" -type f \\( %s \\) 2>/dev/null', target_directory, combined_patterns)
    end
    
    local command_successful, command_handle = pcall(io.popen, platform_find_command)
    if not command_successful or not command_handle then
        utils.log_plugin_error("Failed to scan directory: " .. tostring(target_directory))
        return discovered_image_files
    end
    
    local file_processing_successful, processing_result = pcall(function()
        for discovered_file_path in command_handle:lines() do
            if discovered_file_path and discovered_file_path ~= "" and utils.verify_file_exists_at_path(discovered_file_path) then
                table.insert(discovered_image_files, discovered_file_path)
            end
        end
    end)
    
    command_handle:close()
    
    if not file_processing_successful then
        utils.log_plugin_error("Error reading files from directory: " .. tostring(target_directory))
    end
    
    return discovered_image_files
end

function scanner.refresh_discovered_image_files(active_configuration)
    local current_time = os.time()
    if current_time - state.plugin_state.last_directory_scan_time > active_configuration.directory_scan_interval then
        local previous_image_count = #state.plugin_state.discovered_image_files
        state.plugin_state.discovered_image_files = scanner.scan_directory_for_supported_image_files(active_configuration.image_directory)
        state.plugin_state.last_directory_scan_time = current_time
        
        if #state.plugin_state.discovered_image_files == 0 then
            utils.log_plugin_warning("No images found in directory: " .. active_configuration.image_directory)
        elseif #state.plugin_state.discovered_image_files ~= previous_image_count then
            utils.log_plugin_info("Image list refreshed: " .. #state.plugin_state.discovered_image_files .. " images found")
        end
        
        if state.plugin_state.current_image_list_index > #state.plugin_state.discovered_image_files then
            state.plugin_state.current_image_list_index = math.max(1, #state.plugin_state.discovered_image_files)
        end
    end
end

function scanner.select_random_image_from_discovered_files(active_configuration)
    scanner.refresh_discovered_image_files(active_configuration)
    if #state.plugin_state.discovered_image_files > 0 then
        math.randomseed(os.time())
        local random_index = math.random(#state.plugin_state.discovered_image_files)
        state.plugin_state.current_image_list_index = random_index
        state.plugin_state.current_background_image_path = state.plugin_state.discovered_image_files[random_index]
        return state.plugin_state.current_background_image_path
    end
    utils.log_plugin_warning("No images available for random selection")
    return nil
end

function scanner.select_next_image_from_discovered_files(active_configuration)
    scanner.refresh_discovered_image_files(active_configuration)
    if #state.plugin_state.discovered_image_files > 0 then
        state.plugin_state.current_image_list_index = (state.plugin_state.current_image_list_index % #state.plugin_state.discovered_image_files) + 1
        state.plugin_state.current_background_image_path = state.plugin_state.discovered_image_files[state.plugin_state.current_image_list_index]
        return state.plugin_state.current_background_image_path
    end
    return nil
end

function scanner.select_previous_image_from_discovered_files(active_configuration)
    scanner.refresh_discovered_image_files(active_configuration)
    if #state.plugin_state.discovered_image_files > 0 then
        state.plugin_state.current_image_list_index = state.plugin_state.current_image_list_index - 1
        if state.plugin_state.current_image_list_index < 1 then
            state.plugin_state.current_image_list_index = #state.plugin_state.discovered_image_files
        end
        state.plugin_state.current_background_image_path = state.plugin_state.discovered_image_files[state.plugin_state.current_image_list_index]
        return state.plugin_state.current_background_image_path
    end
    return nil
end

return scanner