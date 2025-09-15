local wezterm = require('wezterm')
local utils = require('wallpaper_manager.utils')
local state = require('wallpaper_manager.state')
local scanner = require('wallpaper_manager.scanner')
local background = require('wallpaper_manager.background')

local rotation = {}

function rotation.determine_next_rotation_image()
    scanner.refresh_discovered_image_files()
    if #state.plugin_state.discovered_image_files == 0 then
        return nil
    end
    
    if state.plugin_state.rotate_mode == "random" then
        return scanner.select_random_image_from_discovered_files()
    else
        return scanner.select_next_image_from_discovered_files()
    end
end

function rotation.initialize_automatic_image_rotation()
    if state.plugin_state.auto_rotate_interval <= 0 then
        return
    end
    
    local rotation_setup_successful, setup_error = pcall(function()
        wezterm.time.call_after(state.plugin_state.auto_rotate_interval, function()
            local current_timestamp = os.time()
            if current_timestamp - state.plugin_state.last_auto_rotation_time >= state.plugin_state.auto_rotate_interval then
                state.plugin_state.last_auto_rotation_time = current_timestamp
                
                local next_rotation_image = rotation.determine_next_rotation_image()
                if next_rotation_image and state.plugin_state.is_background_display_enabled then
                    if not wezterm.mux then
                        utils.log_plugin_error("Mux not available for auto-rotation")
                        return
                    end
                    
                    local windows_retrieval_successful, available_windows = pcall(wezterm.mux.all_windows, wezterm.mux)
                    if not windows_retrieval_successful or not available_windows then
                        utils.log_plugin_error("Failed to get windows for auto-rotation")
                        return
                    end
                    
                    for _, window_instance in ipairs(available_windows) do
                        local gui_window = window_instance:gui_window()
                        if gui_window then
                            local window_update_successful = pcall(function()
                                gui_window:set_config_overrides({
                                    background = background.create_background_layers_with_image(next_rotation_image)
                                })
                            end)
                            if not window_update_successful then
                                utils.log_plugin_error("Failed to update window background during auto-rotation")
                            end
                        end
                    end
                    utils.log_plugin_info("Auto-rotated to image: " .. next_rotation_image)
                    state.save_persistent_state()
                end
            end
            
            rotation.initialize_automatic_image_rotation()
        end)
    end)
    
    if not rotation_setup_successful then
        utils.log_plugin_error("Failed to setup auto-rotation: " .. tostring(setup_error))
    end
end

return rotation