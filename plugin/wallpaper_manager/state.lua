local state = {}

local wezterm = require('wezterm')
local utils = require('wallpaper_manager.utils')

state.plugin_state = {
    current_background_image_path = nil,
    discovered_image_files = {},
    last_directory_scan_time = 0,
    is_background_display_enabled = true,
    current_image_list_index = 1,
    current_size_mode_index = 1,
    last_auto_rotation_time = 0,
    image_directory = nil,
    image_opacity = 1.0,
    image_brightness = 1.0,
    image_saturation = 1.0,
    image_hue = 1.0,
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

function state.get_current_image()
    return state.plugin_state.current_background_image_path
end

function state.get_image_count()
    return #state.plugin_state.discovered_image_files
end

function state.reload_images()
    state.plugin_state.last_directory_scan_time = 0
end

function state.is_background_enabled()
    return state.plugin_state.is_background_display_enabled
end

function state.get_current_size_mode()
    if state.plugin_state.available_size_modes then
        local index = state.plugin_state.current_size_mode_index or 1
        return state.plugin_state.available_size_modes[index] or "Contain"
    end
    return "Contain"
end

function state.initialize_state_with_configuration(merged_configuration)
    local runtime_properties = {
        "current_background_image_path",
        "discovered_image_files", 
        "last_directory_scan_time",
        "is_background_display_enabled",
        "current_image_list_index",
        "current_size_mode_index", 
        "last_auto_rotation_time"
    }
    
    local persistent_data = wezterm.GLOBAL.wallpaper_manager_state
    if persistent_data then
        for _, prop in ipairs(runtime_properties) do
            local value = persistent_data[prop]
            if value ~= nil then
                state.plugin_state[prop] = value
            end
        end
    end
    
    for config_key, config_value in pairs(merged_configuration) do
        local is_runtime_property = false
        for _, runtime_prop in ipairs(runtime_properties) do
            if config_key == runtime_prop then
                is_runtime_property = true
                break
            end
        end
        
        if not is_runtime_property then
            state.plugin_state[config_key] = config_value
        end
    end
    
    state.save_persistent_state()
end

function state.save_persistent_state()
    local runtime_properties = {
        "current_background_image_path",
        "discovered_image_files", 
        "last_directory_scan_time",
        "is_background_display_enabled",
        "current_image_list_index",
        "current_size_mode_index", 
        "last_auto_rotation_time"
    }
    
    wezterm.GLOBAL.wallpaper_manager_state = wezterm.GLOBAL.wallpaper_manager_state or {}
    for _, prop in ipairs(runtime_properties) do
        wezterm.GLOBAL.wallpaper_manager_state[prop] = state.plugin_state[prop]
    end
    
end

return state