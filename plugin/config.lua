local wezterm = require('wezterm')
local utils = require('plugin.utils')

local config = {}

local function determine_default_images_directory()
    local wezterm_config_directory = wezterm.config_dir
    if wezterm_config_directory then
        return wezterm_config_directory .. utils.directory_separator .. "images"
    end
    
    local user_home_directory = os.getenv("HOME") or os.getenv("USERPROFILE")
    if user_home_directory then
        if utils.is_windows_platform then
            return user_home_directory .. "\\AppData\\Local\\wezterm\\images"
        else
            return user_home_directory .. "/.config/wezterm/images"
        end
    end
    
    return "." .. utils.directory_separator .. "images"
end

config.plugin_default_configuration = {
    image_directory = determine_default_images_directory(),
    image_opacity = 1.0,
    image_brightness = 1.0,
    image_saturation = 1.0,
    image_hue = 1.0,
    image_width = "Contain",
    image_height = "Contain",
    image_horizontal_align = "Center",
    image_vertical_align = "Middle",
    image_attachment_mode = "Fixed",
    image_repeat_x = "NoRepeat",
    image_repeat_y = "NoRepeat",
    directory_scan_interval = 60,
    auto_rotate_interval = 300,
    rotate_mode = "random",
    background_color = nil,
    background_layer_opacity = 1.0,
    background_layer_width = "100%",
    background_layer_height = "100%",
    available_size_modes = {"Contain", "Cover", "75%", "100%", "125%", "150%"},
}

function config.validate_user_configuration(user_config)
    local validation_errors = {}
    
    if user_config.auto_rotate_interval and (type(user_config.auto_rotate_interval) ~= "number" or user_config.auto_rotate_interval < 0) then
        table.insert(validation_errors, "auto_rotate_interval must be a non-negative number")
    end
    
    if user_config.rotate_mode and user_config.rotate_mode ~= "random" and user_config.rotate_mode ~= "sequential" then
        table.insert(validation_errors, "rotate_mode must be 'random' or 'sequential'")
    end
    
    if user_config.image_opacity and (type(user_config.image_opacity) ~= "number" or user_config.image_opacity < 0 or user_config.image_opacity > 1) then
        table.insert(validation_errors, "image_opacity must be a number between 0 and 1")
    end
    
    if user_config.directory_scan_interval and (type(user_config.directory_scan_interval) ~= "number" or user_config.directory_scan_interval < 0) then
        table.insert(validation_errors, "directory_scan_interval must be a non-negative number")
    end
    
    return validation_errors
end


function config.merge_configurations(user_provided_options)
    user_provided_options = user_provided_options or {}
    
    local merged_plugin_configuration = {}
    for configuration_key, default_value in pairs(config.plugin_default_configuration) do
        merged_plugin_configuration[configuration_key] = user_provided_options[configuration_key] or default_value
    end
    
    merged_plugin_configuration.background_color = user_provided_options.background_color or config.plugin_default_configuration.background_color
    
    return merged_plugin_configuration
end

return config
