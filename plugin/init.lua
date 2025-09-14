local wezterm = require('wezterm')

local pub = {
    version = "1.0.0"
}

local function init()
    local function setup_plugin_path()
        local separator = package.config:sub(1, 1) == '\\' and '\\' or '/'
        for _, plugin in ipairs(wezterm.plugin.list()) do
            if plugin.url == "https://github.com/jproberson/wallpaper_manager.wezterm" then
                package.path = package.path .. ';' .. plugin.plugin_dir .. separator .. 'plugin' .. separator .. '?.lua'
                package.path = package.path .. ';' .. plugin.plugin_dir .. separator .. 'plugin' .. separator .. '?' .. separator .. 'init.lua'
                break
            end
        end
    end
    
    setup_plugin_path()
    
    local core = require('wallpaper_manager.core')
    pub.apply_to_config = core.apply_to_config
    pub.enable_defaults = core.enable_defaults
    pub.actions = core.actions
    pub.get_current_image = core.get_current_image
    pub.get_image_count = core.get_image_count
    pub.reload_images = core.reload_images
    pub.is_background_enabled = core.is_background_enabled
    pub.get_current_size_mode = core.get_current_size_mode
end

init()

return pub