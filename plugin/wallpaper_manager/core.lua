local wezterm = require('wezterm')
local utils = require('wallpaper_manager.utils')
local config = require('wallpaper_manager.config')
local state = require('wallpaper_manager.state')
local scanner = require('wallpaper_manager.scanner')
local background = require('wallpaper_manager.background')
local actions = require('wallpaper_manager.actions')
local rotation = require('wallpaper_manager.rotation')

local core = {}

function core.apply_to_config(wezterm_config, user_provided_options)
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
    
    config.set_active_configuration(merged_plugin_configuration)
    
    if not utils.verify_directory_exists_at_path(merged_plugin_configuration.image_directory) then
        utils.log_plugin_error("Image directory does not exist: " .. merged_plugin_configuration.image_directory)
        return false
    end
    
    state.plugin_state.current_size_mode_index = 1
    
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

function core.enable_defaults(wezterm_config, user_provided_options)
    if not wezterm_config then
        utils.log_plugin_error("Config table required for enable_defaults")
        return false
    end
    return core.apply_to_config(wezterm_config, user_provided_options)
end

function core.actions()
    return actions.get_actions()
end

function core.get_current_image()
    return state.get_current_image()
end

function core.get_image_count()
    return state.get_image_count()
end

function core.reload_images()
    return state.reload_images()
end

function core.is_background_enabled()
    return state.is_background_enabled()
end

function core.get_current_size_mode()
    return state.get_current_size_mode()
end

return core