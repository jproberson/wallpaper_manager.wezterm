local utils = require('wallpaper_manager.utils')
local state = require('wallpaper_manager.state')

local background = {}

function background.create_wezterm_background_layer_configuration(image_file_path, active_configuration)
    return {
        source = { File = image_file_path },
        width = state.plugin_state.active_image_size_mode,
        height = state.plugin_state.active_image_size_mode,
        horizontal_align = active_configuration.image_horizontal_align,
        vertical_align = active_configuration.image_vertical_align,
        opacity = active_configuration.image_opacity,
        hsb = {
            brightness = active_configuration.image_brightness,
            saturation = active_configuration.image_saturation,
            hue = active_configuration.image_hue
        },
        attachment = active_configuration.image_attachment_mode,
        repeat_x = active_configuration.image_repeat_x,
        repeat_y = active_configuration.image_repeat_y,
    }
end

function background.create_background_layers_with_image(image_path, active_configuration)
    local wezterm = require('wezterm')
    local layers = {}
    
    -- Always add a background color layer to prevent transparency
    local bg_color = active_configuration.background_color or "#000000"
    table.insert(layers, {
        source = { Color = bg_color },
        width = active_configuration.background_layer_width,
        height = active_configuration.background_layer_height,
        opacity = active_configuration.background_layer_opacity
    })
    
    table.insert(layers, background.create_wezterm_background_layer_configuration(image_path, active_configuration))
    return layers
end

function background.create_background_layers_without_image(active_configuration)
    local bg_color = active_configuration.background_color or "#000000"
    return {
        {
            source = { Color = bg_color },
            width = active_configuration.background_layer_width,
            height = active_configuration.background_layer_height,
            opacity = active_configuration.background_layer_opacity
        }
    }
end

function background.apply_current_background_image_to_window(target_window, active_configuration)
    if not target_window then
        utils.log_plugin_error("Invalid window object")
        return false
    end
    
    if state.plugin_state.current_background_image_path and utils.verify_file_exists_at_path(state.plugin_state.current_background_image_path) then
        local background_update_successful, update_error = pcall(function()
            target_window:set_config_overrides({
                background = background.create_background_layers_with_image(state.plugin_state.current_background_image_path, active_configuration)
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

return background