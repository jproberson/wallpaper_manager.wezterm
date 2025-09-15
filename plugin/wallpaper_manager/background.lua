local wezterm = require('wezterm')
local utils = require('wallpaper_manager.utils')
local state = require('wallpaper_manager.state')

local background = {}

function background.create_wezterm_background_layer_configuration(image_file_path)
    local current_size_mode_index = state.plugin_state.current_size_mode_index or 1
    local current_size_mode = state.plugin_state.available_size_modes[current_size_mode_index] or "Contain"
    
    return {
        source = { File = image_file_path },
        width = current_size_mode,
        height = current_size_mode,
        horizontal_align = state.plugin_state.image_horizontal_align,
        vertical_align = state.plugin_state.image_vertical_align,
        opacity = state.plugin_state.image_opacity,
        hsb = {
            brightness = state.plugin_state.image_brightness,
            saturation = state.plugin_state.image_saturation,
            hue = state.plugin_state.image_hue
        },
        attachment = state.plugin_state.image_attachment_mode,
        repeat_x = state.plugin_state.image_repeat_x,
        repeat_y = state.plugin_state.image_repeat_y,
    }
end

function background.create_background_layers_with_image(image_path)
    local layers = {}
    
    local bg_color = state.plugin_state.background_color or "#000000"
    table.insert(layers, {
        source = { Color = bg_color },
        width = state.plugin_state.background_layer_width,
        height = state.plugin_state.background_layer_height,
        opacity = state.plugin_state.background_layer_opacity
    })
    
    table.insert(layers, background.create_wezterm_background_layer_configuration(image_path))
    return layers
end

function background.create_background_layers_without_image()
    local bg_color = state.plugin_state.background_color or "#000000"
    return {
        {
            source = { Color = bg_color },
            width = state.plugin_state.background_layer_width,
            height = state.plugin_state.background_layer_height,
            opacity = state.plugin_state.background_layer_opacity
        }
    }
end

function background.apply_current_background_image_to_window(target_window)
    if not target_window then
        utils.log_plugin_error("Invalid window object")
        return false
    end
    
    if state.plugin_state.current_background_image_path and utils.verify_file_exists_at_path(state.plugin_state.current_background_image_path) then
        local background_update_successful, update_error = pcall(function()
            target_window:set_config_overrides({
                background = background.create_background_layers_with_image(state.plugin_state.current_background_image_path)
            })
        end)
        
        if not background_update_successful then
            utils.log_plugin_error("Failed to update background: " .. tostring(update_error))
            return false
        end
        return true
    else
        utils.log_plugin_warning("No valid current image to display")
        return false
    end
end

function background.refresh_all_windows_with_current_state()
    if not wezterm.mux then
        return false
    end
    
    local windows_retrieval_successful, available_windows = pcall(wezterm.mux.all_windows, wezterm.mux)
    if not windows_retrieval_successful or not available_windows then
        return false
    end
    
    for _, window_instance in ipairs(available_windows) do
        local gui_window = window_instance:gui_window()
        if gui_window then
            local window_update_successful = pcall(function()
                if state.plugin_state.current_background_image_path then
                    gui_window:set_config_overrides({
                        background = background.create_background_layers_with_image(state.plugin_state.current_background_image_path)
                    })
                else
                    gui_window:set_config_overrides({})
                end
            end)
        end
    end
    return true
end

return background