local wezterm = require('wezterm')

local utils = require('plugin.utils')
local config = require('plugin.config')
local state = require('plugin.state')
local scanner = require('plugin.scanner')
local background = require('plugin.background')
local actions = require('plugin.actions')
local rotation = require('plugin.rotation')

local image_handler_plugin = {
    version = "1.0.0"
}

function image_handler_plugin.apply_to_config(wezterm_config, user_provided_options)
    user_provided_options = user_provided_options or {}
    
    local configuration_validation_errors = config.validate_user_configuration(user_provided_options)
    if #configuration_validation_errors > 0 then
        for _, validation_error in ipairs(configuration_validation_errors) do
            utils.log_plugin_error("Configuration error: " .. validation_error)
        end
        utils.log_plugin_error("Plugin not loaded due to configuration errors")
        return false
    end
    
    local merged_plugin_configuration = config.merge_configurations(user_provided_options)
    
    if not utils.verify_directory_exists_at_path(merged_plugin_configuration.image_directory) then
        utils.log_plugin_error("Image directory does not exist: " .. merged_plugin_configuration.image_directory)
        return false
    end
    
    state.plugin_state.available_size_modes = merged_plugin_configuration.available_size_modes
    state.plugin_state.active_image_size_mode = merged_plugin_configuration.available_size_modes[1]
    
    scanner.refresh_discovered_image_files(merged_plugin_configuration)
    utils.log_plugin_info("Found " .. #state.plugin_state.discovered_image_files .. " images in " .. merged_plugin_configuration.image_directory)
    
    if not state.plugin_state.current_background_image_path and #state.plugin_state.discovered_image_files > 0 then
        state.plugin_state.current_background_image_path = state.plugin_state.discovered_image_files[1]
        state.plugin_state.current_image_list_index = 1
        utils.log_plugin_info("Setting initial background to " .. state.plugin_state.current_background_image_path)
        
        wezterm_config.background = background.create_background_layers_with_image(state.plugin_state.current_background_image_path, merged_plugin_configuration)
    else
        if #state.plugin_state.discovered_image_files == 0 then
            utils.log_plugin_warning("No images found, using solid background")
        end
        wezterm_config.background = background.create_background_layers_without_image(merged_plugin_configuration)
    end
    
    if merged_plugin_configuration.auto_rotate_interval > 0 then
        state.plugin_state.last_auto_rotation_time = os.time()
        rotation.initialize_automatic_image_rotation(merged_plugin_configuration)
        utils.log_plugin_info("Auto-rotation enabled: " .. merged_plugin_configuration.auto_rotate_interval .. "s (" .. merged_plugin_configuration.rotate_mode .. " mode)")
    end
    
    utils.log_plugin_info("Plugin loaded with " .. #state.plugin_state.discovered_image_files .. " images")
    return true
end

image_handler_plugin.get_current_image = function()
    return state.get_current_image()
end

image_handler_plugin.get_image_count = function()
    return state.get_image_count()
end

image_handler_plugin.reload_images = function()
    return state.reload_images()
end

image_handler_plugin.is_background_enabled = function()
    return state.is_background_enabled()
end

image_handler_plugin.get_current_size_mode = function()
    return state.get_current_size_mode()
end

image_handler_plugin.enable_defaults = function(wezterm_config, user_provided_options)
    if not wezterm_config then
        utils.log_plugin_error("Config table required for enable_defaults")
        return false
    end
    return image_handler_plugin.apply_to_config(wezterm_config, user_provided_options)
end

image_handler_plugin.actions = function(plugin_configuration)
    return actions.get_actions(plugin_configuration)
end

return image_handler_plugin