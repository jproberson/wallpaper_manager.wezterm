local state = {}

state.plugin_state = {
    current_background_image_path = nil,
    discovered_image_files = {},
    last_directory_scan_time = 0,
    is_background_display_enabled = true,
    current_image_list_index = 1,
    current_size_mode_index = 1,
    last_auto_rotation_time = 0,
    rotation_timer_handle = nil,
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
    local config = require('wallpaper_manager.config')
    local active_config = config.get_active_configuration()
    if active_config and active_config.available_size_modes then
        local index = state.plugin_state.current_size_mode_index or 1
        return active_config.available_size_modes[index] or "Contain"
    end
    return "Contain"
end

function state.reset_state()
    state.plugin_state.current_background_image_path = nil
    state.plugin_state.discovered_image_files = {}
    state.plugin_state.last_directory_scan_time = 0
    state.plugin_state.is_background_display_enabled = true
    state.plugin_state.current_image_list_index = 1
    state.plugin_state.current_size_mode_index = 1
    state.plugin_state.last_auto_rotation_time = 0
    state.plugin_state.rotation_timer_handle = nil
end

return state