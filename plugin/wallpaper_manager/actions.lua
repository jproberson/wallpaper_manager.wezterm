local wezterm = require('wezterm')
local utils = require('wallpaper_manager.utils')
local state = require('wallpaper_manager.state')
local scanner = require('wallpaper_manager.scanner')
local background = require('wallpaper_manager.background')
local sizing = require('wallpaper_manager.sizing')

local actions = {}


function actions.create_random_image_selection_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local selected_image_path = scanner.select_random_image_from_discovered_files()
        if selected_image_path then
            local success, error = pcall(function()
                target_window:set_config_overrides({
                    background = background.create_background_layers_with_image(selected_image_path)
                })
                state.save_persistent_state()
            end)
            if not success then
                utils.log_plugin_error("Failed to set random background image: " .. tostring(error))
            end
        end
    end)
end

function actions.create_next_image_selection_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local selected_image_path = scanner.select_next_image_from_discovered_files()
        if selected_image_path then
            local success, error = pcall(function()
                target_window:set_config_overrides({
                    background = background.create_background_layers_with_image(selected_image_path)
                })
                state.save_persistent_state()
            end)
            if not success then
                utils.log_plugin_error("Failed to set next background image: " .. tostring(error))
            end
        end
    end)
end

function actions.create_previous_image_selection_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local selected_image_path = scanner.select_previous_image_from_discovered_files()
        if selected_image_path then
            local success, error = pcall(function()
                target_window:set_config_overrides({
                    background = background.create_background_layers_with_image(selected_image_path)
                })
                state.save_persistent_state()
            end)
            if not success then
                utils.log_plugin_error("Failed to set previous background image: " .. tostring(error))
            end
        end
    end)
end

function actions.create_background_display_toggle_action()
    return wezterm.action_callback(function(target_window, target_pane)
        state.plugin_state.is_background_display_enabled = not state.plugin_state.is_background_display_enabled
        if state.plugin_state.is_background_display_enabled and state.plugin_state.current_background_image_path then
            if background.apply_current_background_image_to_window(target_window) then
                utils.log_plugin_info("Background image enabled")
            else
                utils.log_plugin_error("Failed to enable background image")
                state.plugin_state.is_background_display_enabled = false
            end
        else
            local success, error_msg = pcall(function()
                target_window:set_config_overrides({
                    background = background.create_background_layers_without_image()
                })
            end)
            if success then
                utils.log_plugin_info("Background image disabled")
            else
                utils.log_plugin_error("Failed to disable background image: " .. tostring(error_msg))
            end
        end
    end)
end

function actions.create_image_directory_reload_action()
    return wezterm.action_callback(function(target_window, target_pane)
        state.plugin_state.last_directory_scan_time = 0
        scanner.refresh_discovered_image_files()
        utils.log_plugin_info("Image list reloaded: " .. #state.plugin_state.discovered_image_files .. " images found")
    end)
end

function actions.create_image_size_increase_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local new_size_mode = sizing.increase_current_image_size_mode()
        utils.log_plugin_info("Image size increased to: " .. new_size_mode)
        background.apply_current_background_image_to_window(target_window)
    end)
end

function actions.create_image_size_decrease_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local new_size_mode = sizing.decrease_current_image_size_mode()
        utils.log_plugin_info("Image size decreased to: " .. new_size_mode)
        background.apply_current_background_image_to_window(target_window)
    end)
end

function actions.create_image_size_cycle_action()
    return wezterm.action_callback(function(target_window, target_pane)
        local new_size_mode = sizing.cycle_to_next_image_size_mode()
        utils.log_plugin_info("Image size cycled to: " .. new_size_mode)
        background.apply_current_background_image_to_window(target_window)
    end)
end

function actions.get_actions()
    return {
        select_random_image = actions.create_random_image_selection_action(),
        select_next_image = actions.create_next_image_selection_action(),
        select_previous_image = actions.create_previous_image_selection_action(),
        toggle_background_display = actions.create_background_display_toggle_action(),
        reload_image_directory = actions.create_image_directory_reload_action(),
        increase_image_size = actions.create_image_size_increase_action(),
        decrease_image_size = actions.create_image_size_decrease_action(),
        cycle_image_size_modes = actions.create_image_size_cycle_action()
    }
end

return actions
