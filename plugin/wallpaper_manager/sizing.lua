local state = require('wallpaper_manager.state')
local config = require('wallpaper_manager.config')

local sizing = {}

function sizing.cycle_to_next_image_size_mode()
    local active_config = config.get_active_configuration()
    if not active_config or not active_config.available_size_modes then
        return "Contain"
    end
    
    state.plugin_state.current_size_mode_index = (state.plugin_state.current_size_mode_index % #active_config.available_size_modes) + 1
    return active_config.available_size_modes[state.plugin_state.current_size_mode_index]
end

function sizing.increase_current_image_size_mode()
    local active_config = config.get_active_configuration()
    if not active_config or not active_config.available_size_modes then
        return "Contain"
    end
    
    local next_size_index = state.plugin_state.current_size_mode_index + 1
    if next_size_index <= #active_config.available_size_modes then
        state.plugin_state.current_size_mode_index = next_size_index
    end
    return active_config.available_size_modes[state.plugin_state.current_size_mode_index]
end

function sizing.decrease_current_image_size_mode()
    local active_config = config.get_active_configuration()
    if not active_config or not active_config.available_size_modes then
        return "Contain"
    end
    
    local previous_size_index = state.plugin_state.current_size_mode_index - 1
    if previous_size_index >= 1 then
        state.plugin_state.current_size_mode_index = previous_size_index
    end
    return active_config.available_size_modes[state.plugin_state.current_size_mode_index]
end

return sizing