local state = require('wallpaper_manager.state')

local sizing = {}

function sizing.cycle_to_next_image_size_mode()
    state.plugin_state.current_size_mode_index = (state.plugin_state.current_size_mode_index % #state.plugin_state.available_size_modes) + 1
    state.plugin_state.active_image_size_mode = state.plugin_state.available_size_modes[state.plugin_state.current_size_mode_index]
    return state.plugin_state.active_image_size_mode
end

function sizing.increase_current_image_size_mode()
    local next_size_index = state.plugin_state.current_size_mode_index + 1
    if next_size_index <= #state.plugin_state.available_size_modes then
        state.plugin_state.current_size_mode_index = next_size_index
        state.plugin_state.active_image_size_mode = state.plugin_state.available_size_modes[state.plugin_state.current_size_mode_index]
    end
    return state.plugin_state.active_image_size_mode
end

function sizing.decrease_current_image_size_mode()
    local previous_size_index = state.plugin_state.current_size_mode_index - 1
    if previous_size_index >= 1 then
        state.plugin_state.current_size_mode_index = previous_size_index
        state.plugin_state.active_image_size_mode = state.plugin_state.available_size_modes[state.plugin_state.current_size_mode_index]
    end
    return state.plugin_state.active_image_size_mode
end

return sizing