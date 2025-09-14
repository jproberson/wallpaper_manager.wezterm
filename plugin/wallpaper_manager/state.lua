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
    image_directory = nil,
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

function state.reset_state()
    state.plugin_state.current_background_image_path = nil
    state.plugin_state.discovered_image_files = {}
    state.plugin_state.last_directory_scan_time = 0
    state.plugin_state.is_background_display_enabled = true
    state.plugin_state.current_image_list_index = 1
    state.plugin_state.current_size_mode_index = 1
    state.plugin_state.last_auto_rotation_time = 0
    state.plugin_state.rotation_timer_handle = nil
    state.plugin_state.image_directory = nil
    state.plugin_state.image_opacity = 1.0
    state.plugin_state.image_brightness = 1.0
    state.plugin_state.image_saturation = 1.0
    state.plugin_state.image_hue = 1.0
    state.plugin_state.image_width = "Contain"
    state.plugin_state.image_height = "Contain"
    state.plugin_state.image_horizontal_align = "Center"
    state.plugin_state.image_vertical_align = "Middle"
    state.plugin_state.image_attachment_mode = "Fixed"
    state.plugin_state.image_repeat_x = "NoRepeat"
    state.plugin_state.image_repeat_y = "NoRepeat"
    state.plugin_state.directory_scan_interval = 60
    state.plugin_state.auto_rotate_interval = 300
    state.plugin_state.rotate_mode = "random"
    state.plugin_state.background_color = nil
    state.plugin_state.background_layer_opacity = 1.0
    state.plugin_state.background_layer_width = "100%"
    state.plugin_state.background_layer_height = "100%"
    state.plugin_state.available_size_modes = {"Contain", "Cover", "75%", "100%", "125%", "150%"}
end

function state.initialize_state_with_configuration(merged_configuration)
    for config_key, config_value in pairs(merged_configuration) do
        state.plugin_state[config_key] = config_value
    end
end

return state