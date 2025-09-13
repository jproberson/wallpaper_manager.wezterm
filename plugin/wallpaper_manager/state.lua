local state = {}

state.plugin_state = {
    current_background_image_path = nil,
    discovered_image_files = {},
    last_directory_scan_time = 0,
    is_background_display_enabled = true,
    current_image_list_index = 1,
    active_image_size_mode = "Contain",
    available_size_modes = {},
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
    return state.plugin_state.active_image_size_mode
end

function state.reset_state()
    state.plugin_state.current_background_image_path = nil
    state.plugin_state.discovered_image_files = {}
    state.plugin_state.last_directory_scan_time = 0
    state.plugin_state.is_background_display_enabled = true
    state.plugin_state.current_image_list_index = 1
    state.plugin_state.active_image_size_mode = "Contain"
    state.plugin_state.available_size_modes = {}
    state.plugin_state.current_size_mode_index = 1
    state.plugin_state.last_auto_rotation_time = 0
    state.plugin_state.rotation_timer_handle = nil
end

return state